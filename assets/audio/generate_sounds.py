# Simple sound generator for Space Dodger
# This script generates basic .wav files using Python's built-in capabilities
# Run: python generate_sounds.py

import wave
import struct
import math
import os

SAMPLE_RATE = 44100

def generate_tone(frequency, duration, volume=0.5, filename="tone.wav", fade_out=False):
    """Generate a simple tone with optional fade out"""
    n_samples = int(SAMPLE_RATE * duration)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        for i in range(n_samples):
            t = i / SAMPLE_RATE
            # Generate sine wave
            value = volume * math.sin(2 * math.pi * frequency * t)
            
            # Apply fade out if requested
            if fade_out:
                fade_factor = 1 - (i / n_samples)
                value *= fade_factor
            
            # Convert to 16-bit integer
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframes(packed_value)

def generate_collision_sound():
    """Generate collision/explosion sound - white noise burst"""
    n_samples = int(SAMPLE_RATE * 0.4)
    
    with wave.open('collision.wav', 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        import random
        random.seed(42)  # Reproducible sound
        
        for i in range(n_samples):
            t = i / SAMPLE_RATE
            # White noise with exponential decay
            noise = random.uniform(-1, 1)
            fade_factor = math.exp(-5 * t)  # Exponential decay
            value = noise * fade_factor * 0.6
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframes(packed_value)

def generate_powerup_sound():
    """Generate power-up collection sound (ascending chirp)"""
    n_samples = int(SAMPLE_RATE * 0.3)
    
    with wave.open('powerup.wav', 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        for i in range(n_samples):
            t = i / SAMPLE_RATE
            # Frequency sweep from 440Hz to 880Hz (ascending chirp)
            frequency = 440 + t * 1467  # 440Hz to 880Hz over 0.3s
            value = 0.4 * math.sin(2 * math.pi * frequency * t)
            # Apply envelope
            envelope = math.sin(math.pi * t / 0.3)  # Smooth attack and decay
            value *= envelope
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframes(packed_value)

def generate_gameover_sound():
    """Generate game over sound (descending tones)"""
    n_samples = int(SAMPLE_RATE * 1.2)
    
    with wave.open('gameover.wav', 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        for i in range(n_samples):
            t = i / SAMPLE_RATE
            # Descending frequency from 440Hz to 110Hz
            frequency = 440 - t * 275  # 440Hz to 110Hz
            fade_factor = 1 - (i / n_samples)
            value = 0.5 * math.sin(2 * math.pi * frequency * t) * fade_factor
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframes(packed_value)

def generate_level_complete_sound():
    """Generate level complete sound (ascending arpeggio)"""
    n_samples = int(SAMPLE_RATE * 0.8)
    
    with wave.open('level_complete.wav', 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        # C major arpeggio: C5, E5, G5, C6
        frequencies = [523.25, 659.25, 783.99, 1046.50]
        note_duration = 0.18  # seconds per note
        
        for i in range(n_samples):
            t = i / SAMPLE_RATE
            note_index = min(int(t / note_duration), 3)
            freq = frequencies[note_index]
            
            # ADSR envelope for each note
            note_t = t % note_duration
            if note_t < 0.02:  # Attack
                envelope = note_t / 0.02
            elif note_t < 0.15:  # Decay/Sustain
                envelope = 0.8
            else:  # Release
                envelope = 0.8 * (1 - (note_t - 0.15) / 0.03)
            
            value = 0.35 * math.sin(2 * math.pi * freq * t) * envelope
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframes(packed_value)

def generate_background_music():
    """Generate upbeat, happy 8-bit chip-tune background music"""
    n_samples = int(SAMPLE_RATE * 6.4)  # 6.4 seconds loop
    
    with wave.open('background_music.wav', 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        # Happy fast melody (C major pentatonic-ish)
        # Sequence of notes and their durations (1 = quarter note, 0.5 = eighth note)
        # BPM = 150 -> 1 beat = 0.4s
        beat_dur = 0.4
        
        melody = [
            (523.25, 0.5), (659.25, 0.5), (783.99, 1.0), (1046.50, 0.5), (783.99, 1.5),
            (659.25, 0.5), (523.25, 0.5), (659.25, 0.5), (783.99, 0.5), (1046.50, 2.0),
            (1046.50, 0.5), (1318.51, 0.5), (1567.98, 1.0), (1046.50, 0.5), (783.99, 1.5),
            (659.25, 0.5), (783.99, 0.5), (659.25, 0.5), (523.25, 0.5), (392.00, 2.0)
        ]
        
        bassline = [
            (130.81, 1.0), (196.00, 1.0), (261.63, 1.0), (196.00, 1.0),
            (130.81, 1.0), (174.61, 1.0), (261.63, 1.0), (174.61, 1.0),
            (130.81, 1.0), (196.00, 1.0), (261.63, 1.0), (196.00, 1.0),
            (130.81, 1.0), (164.81, 1.0), (196.00, 1.0), (164.81, 1.0)
        ]
        
        current_melody_idx = 0
        melody_time_remaining = melody[0][1] * beat_dur
        
        current_bass_idx = 0
        bass_time_remaining = bassline[0][1] * beat_dur
        
        for i in range(n_samples):
            t = 1.0 / SAMPLE_RATE
            
            # Melody (square wave-like via sine harmonics for chippy sound)
            melody_freq = melody[current_melody_idx][0]
            melody_vol = 0.25
            m_val = math.sin(2 * math.pi * melody_freq * (i / SAMPLE_RATE))
            m_val += 0.3 * math.sin(2 * math.pi * (melody_freq * 3) * (i / SAMPLE_RATE)) # odd harmonic
            
            # Envelope for melody (staccato)
            note_duration = melody[current_melody_idx][1] * beat_dur
            note_t = note_duration - melody_time_remaining
            m_env = 1.0
            if note_t < 0.01:
                m_env = note_t / 0.01
            elif melody_time_remaining < 0.05:
                m_env = max(0, melody_time_remaining / 0.05)
            
            # Bassline (triangle-like)
            bass_freq = bassline[current_bass_idx][0]
            bass_vol = 0.35
            b_val = math.sin(2 * math.pi * bass_freq * (i / SAMPLE_RATE))
            # Envelope for bass
            b_note_dur = bassline[current_bass_idx][1] * beat_dur
            b_note_t = b_note_dur - bass_time_remaining
            b_env = 1.0
            if b_note_t < 0.02:
                b_env = b_note_t / 0.02
            elif bass_time_remaining < 0.1:
                b_env = max(0, bass_time_remaining / 0.1)
                
            value = (m_val * m_env * melody_vol) + (b_val * b_env * bass_vol)
            
            # Loop fade
            loop_t = i / SAMPLE_RATE
            if loop_t < 0.05:
                value *= loop_t / 0.05
            elif loop_t > 6.4 - 0.05:
                value *= (6.4 - loop_t) / 0.05
                
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframes(packed_value)
            
            melody_time_remaining -= t
            if melody_time_remaining <= 0 and current_melody_idx < len(melody) - 1:
                current_melody_idx += 1
                melody_time_remaining += melody[current_melody_idx][1] * beat_dur
                
            bass_time_remaining -= t
            if bass_time_remaining <= 0 and current_bass_idx < len(bassline) - 1:
                current_bass_idx += 1
                bass_time_remaining += bassline[current_bass_idx][1] * beat_dur

if __name__ == '__main__':
    print("Generating sound effects for Space Dodger...")
    
    generate_collision_sound()
    print("  - collision.wav")
    
    generate_powerup_sound()
    print("  - powerup.wav")
    
    generate_gameover_sound()
    print("  - gameover.wav")
    
    generate_level_complete_sound()
    print("  - level_complete.wav")
    
    generate_background_music()
    print("  - background_music.wav")
    
    print("\nAll sounds generated successfully!")
