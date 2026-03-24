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
    """Generate simple looping ambient background music"""
    n_samples = int(SAMPLE_RATE * 8)  # 8 seconds loop
    
    with wave.open('background_music.wav', 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        # Ambient drone with subtle modulation
        # Base: A2 (110Hz), E3 (164.81Hz), A3 (220Hz)
        base_freqs = [110.0, 164.81, 220.0]
        base_volumes = [0.15, 0.1, 0.1]
        
        for i in range(n_samples):
            t = i / SAMPLE_RATE
            
            # Base drone
            value = 0.0
            for freq, vol in zip(base_freqs, base_volumes):
                value += vol * math.sin(2 * math.pi * freq * t)
            
            # Add subtle high harmonic
            value += 0.05 * math.sin(2 * math.pi * 440 * t)
            
            # Very subtle modulation to avoid static sound
            modulation = 0.02 * math.sin(2 * math.pi * 0.25 * t)
            value += modulation
            
            # Soft fade in/out for seamless looping
            loop_fade = math.sin(math.pi * t / 8) ** 0.1
            value *= loop_fade
            
            packed_value = struct.pack('<h', int(value * 32767))
            wav_file.writeframes(packed_value)

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
