/**
 * MixerInstrumentPlayer
 *
 * Wrapper around InstrumentPlayer that adds per-instrument mixer controls:
 * - Play: normal playback (gain unmodified)
 * - Solo: only this instrument plays (gain = 0 for all others)
 * - Mute: this instrument is silent (gain = 0)
 *
 * States rotate: Play → Solo → Mute → Play
 */

import { InstrumentPlayer, PlaybackInstrument } from 'osmd-audio-player/dist/players/InstrumentPlayer'
import { NotePlaybackInstruction } from 'osmd-audio-player/dist/players/NotePlaybackOptions'
import { IAudioContext } from 'standardized-audio-context'

export enum InstrumentState {
    PLAY = 'play',
    SOLO = 'solo',
    MUTE = 'mute'
}

export interface InstrumentChannel {
    index: number
    midiId: number // Primary midiId for this channel
    midiIds: number[] // All midiIds associated with this instrument name
    name: string
    state: InstrumentState
}

export class MixerInstrumentPlayer implements InstrumentPlayer {
    private wrappedPlayer: InstrumentPlayer
    private channelStates: Map<number, InstrumentState> = new Map()
    private scoreInstruments: PlaybackInstrument[] = []
    private midiIdToChannelIndex: Map<number, number> = new Map() // Maps midiId -> channel index

    constructor(player: InstrumentPlayer) {
        this.wrappedPlayer = player
    }

    get instruments(): PlaybackInstrument[] {
        return this.wrappedPlayer.instruments
    }

    /**
     * Set the score instruments explicitly
     * This should be called after playback initialization with the actual score instruments
     */
    setScoreInstruments(instruments: PlaybackInstrument[]): void {
        this.scoreInstruments = instruments
    }

    init(audioContext: IAudioContext): void {
        this.wrappedPlayer.init(audioContext)
    }

    async load(midiId: number): Promise<void> {
        // Just delegate to wrapped player - channel states are managed by index now
        return this.wrappedPlayer.load(midiId)
    }

    play(midiId: string | number, options: any): void {
        return this.wrappedPlayer.play(midiId, options)
    }

    stop(midiId: number): void {
        return this.wrappedPlayer.stop(midiId)
    }

    /**
     * Schedule notes with mixer gain applied
     */
    schedule(midiId: number, time: number, notes: NotePlaybackInstruction[]): void {
        const gainMultiplier = this.getGainMultiplier(midiId)
        const modifiedNotes = notes.map(note => ({
            ...note,
            gain: note.gain * gainMultiplier
        }))

        console.log(`[Mixer] Schedule midiId=${midiId}, gain=${gainMultiplier}, notes=${notes.length}`)
        this.wrappedPlayer.schedule(midiId, time, modifiedNotes)
    }

    /**
     * Get the current state of an instrument channel by index
     */
    getChannelState(index: number): InstrumentState {
        return this.channelStates.get(index) || InstrumentState.PLAY
    }

    /**
     * Set the state of an instrument channel by index
     */
    setChannelState(index: number, state: InstrumentState): void {
        // If setting to SOLO, ensure no other channels are in SOLO
        if (state === InstrumentState.SOLO) {
            for (const [id, _] of this.channelStates) {
                if (id !== index && this.channelStates.get(id) === InstrumentState.SOLO) {
                    this.channelStates.set(id, InstrumentState.PLAY)
                }
            }
        }

        this.channelStates.set(index, state)
    }

    /**
     * Toggle channel state by index: Play → Solo → Mute → Play
     */
    toggleChannelState(index: number): InstrumentState {
        const currentState = this.getChannelState(index)
        let newState: InstrumentState

        switch (currentState) {
            case InstrumentState.PLAY:
                newState = InstrumentState.SOLO
                break
            case InstrumentState.SOLO:
                newState = InstrumentState.MUTE
                break
            case InstrumentState.MUTE:
                newState = InstrumentState.PLAY
                break
            default:
                newState = InstrumentState.PLAY
        }

        this.setChannelState(index, newState)
        return newState
    }

    /**
     * Get all active channels with their states
     * Returns one channel per score instrument
     */
    getChannels(): InstrumentChannel[] {
        const channels: InstrumentChannel[] = []

        // Use scoreInstruments if available, otherwise fall back to wrapped player instruments
        const instrumentsToUse = this.scoreInstruments.length > 0 ? this.scoreInstruments : this.instruments

        console.log(`[Mixer] getChannels: scoreInstruments.length=${this.scoreInstruments.length}, instruments.length=${this.instruments.length}`)
        console.log(`[Mixer] instrumentsToUse:`, instrumentsToUse.map((inst, idx) => `[${idx}] ${inst.name} (midiId=${inst.midiId})`))

        // Create one channel per score instrument using array index as unique ID
        // For each channel, collect ALL midiIds from ALL instruments that have the same name
        instrumentsToUse.forEach((instrument, index) => {
            const state = this.channelStates.get(index) || InstrumentState.PLAY

            // Collect all midiIds from ALL instruments (not just scoreInstruments) with this name
            const allMidiIds = this.instruments
                .filter(inst => inst.name === instrument.name && inst.midiId !== undefined)
                .map(inst => inst.midiId)

            console.log(`[Mixer] Creating channel ${index}: name="${instrument.name}", primaryMidiId=${instrument.midiId}, allMidiIds=[${allMidiIds}], state=${state}`)
            channels.push({
                index: index,
                midiId: instrument.midiId,
                midiIds: allMidiIds,
                name: instrument.name,
                state
            })
        })

        return channels
    }

    /**
     * Reset all channels to PLAY state
     */
    resetAllChannels(): void {
        for (const index of this.channelStates.keys()) {
            this.channelStates.set(index, InstrumentState.PLAY)
        }
    }

    /**
     * Initialize channels for all score instruments
     * Creates one channel per score instrument using array index
     * Also builds the midiId -> channel index mapping
     */
    initializeChannels(): void {
        // Use scoreInstruments if available, otherwise fall back to wrapped player instruments
        const instrumentsToUse = this.scoreInstruments.length > 0 ? this.scoreInstruments : this.instruments

        // Clear previous mapping
        this.midiIdToChannelIndex.clear()

        // Initialize one channel per score instrument with PLAY state
        // Build mapping from ALL midiIds with this instrument name to the channel index
        instrumentsToUse.forEach((instrument, index) => {
            if (!this.channelStates.has(index)) {
                this.channelStates.set(index, InstrumentState.PLAY)
            }

            // Map ALL midiIds from ALL instruments with this name to this channel index
            this.instruments
                .filter(inst => inst.name === instrument.name && inst.midiId !== undefined)
                .forEach(inst => {
                    this.midiIdToChannelIndex.set(inst.midiId, index)
                    console.log(`[Mixer] Mapped midiId ${inst.midiId} (${inst.name}) -> channel ${index}`)
                })
        })
    }

    /**
     * Calculate gain multiplier based on channel states
     * Uses the midiId -> channel index mapping to find which channel controls this midiId
     * - If channel is in SOLO and SOLO mode is active globally, play it
     * - If channel is in PLAY and no SOLO is active, play it
     * - Otherwise mute
     */
    private getGainMultiplier(midiId: number): number {
        // Find which channel this midiId belongs to
        const channelIndex = this.midiIdToChannelIndex.get(midiId)

        if (channelIndex === undefined) {
            console.log(`[Mixer] getGainMultiplier(${midiId}): no channel mapping found, gain=1.0`)
            return 1.0
        }

        const channelState = this.getChannelState(channelIndex)

        // Check if any channel is in SOLO mode
        const hasSolo = Array.from(this.channelStates.values()).some(
            s => s === InstrumentState.SOLO
        )

        console.log(`[Mixer] getGainMultiplier(${midiId}): channelIndex=${channelIndex}, state=${channelState}, hasSolo=${hasSolo}`)

        if (hasSolo) {
            // If this channel is SOLO, play it; otherwise mute it
            const gain = channelState === InstrumentState.SOLO ? 1.0 : 0.0
            console.log(`[Mixer]   -> SOLO mode: gain=${gain}`)
            return gain
        }

        // No SOLO active: if this channel is in PLAY, play it; if MUTE, mute it
        const gain = channelState === InstrumentState.PLAY ? 1.0 : 0.0
        console.log(`[Mixer]   -> NORMAL mode: gain=${gain}`)
        return gain
    }
}
