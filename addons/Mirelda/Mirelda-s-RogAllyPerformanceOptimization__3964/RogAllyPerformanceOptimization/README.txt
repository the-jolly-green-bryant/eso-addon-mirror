### Performance Modes

RAPO now supports two performance modes:

- **45fps mode**  
  This is the default mode and the recommended option for the ROG Ally / Ryzen Z1 Extreme. It is tuned to provide a more stable experience and better overall balance between smoothness and image quality.

- **60fps mode**  
  This mode is available for users who want a higher target frame rate, but it should be used with caution on the Ryzen Z1 Extreme. In many scenes, Z1 Extreme handhelds may not have enough performance headroom to sustain this mode reliably.  
  At the moment, this mode is mainly intended for newer Intel PTL handhelds or other devices with stronger real-world performance in ESO.

If you are using a Z1 Extreme device, **45fps mode is still the recommended baseline**.

### Commands

RAPO currently supports the following commands:

- **/rapo stats**  
  Shows current session statistics and lifetime statistics for the active performance mode.

- **/rapo debug**  
  Toggles debug logging on or off.

- **/rapo mode**  
  Shows the current active performance mode and any pending mode change.

- **/rapo mode 45fps**  
  Queues a switch to 45fps mode. The change is not applied immediately.

- **/rapo mode 60fps**  
  Queues a switch to 60fps mode. The change is not applied immediately.

- **/rapo confirm**  
  Confirms the pending performance mode change and reloads the UI after a short delay.

- **/rapo cancel**  
  Cancels the pending performance mode change.


ROG Ally Performance Optimization

### What It Does

This addon is designed to provide a smoother gaming experience on the ROG Ally by balancing performance and graphics quality. It dynamically adjusts in-game graphics settings based on real-time FPS, aiming to keep your game running at a stable 45 FPS. When FPS drops, it lowers the graphics settings to maintain smooth gameplay, and when FPS stabilizes, it gradually improves the visual quality for the best possible balance.

### What It Changes

The addon makes two types of adjustments:

- **Static Settings**: Right after the game launches, the addon applies a set of static optimizations to ensure a performance-first approach. This includes changes to general graphics, shadows, anti-aliasing, FSR, and more, reducing resource usage.
- **Dynamic Adjustments**: During gameplay, the addon dynamically tweaks 5 key settings based on the current FPS to balance graphics quality and performance:
  - **View Distance**
  - **Sunlight Rays**
  - **Distortion**
  - **Show Additional Ally Effects**
  - **FSR Mode Switching**

### How It Works

1. **Static Settings Initialization**: When the addon loads, it immediately applies static optimizations and locks the four key settings to their lowest values to prioritize performance. For the first 60 seconds after launching the game, the graphics will stay at their lowest to prevent excessive resource usage.

2. **Real-Time FPS Monitoring**: The addon checks the current FPS every 300 milliseconds and makes adjustments accordingly:
   - **Low FPS**: If FPS stays below 44 for about 5.7 seconds, the addon locks the settings to the lowest to ensure smooth performance.
   - **High FPS**: If FPS remains above 44 for 60 seconds, the addon unlocks and starts to gradually increase the quality of the settings.

3. **Dynamic Adjustment Logic**: When the FPS is low and not locked, the addon lowers settings one by one, starting with **View Distance**, followed by **Sunlight Rays**, **Distortion**, and **Show Additional Ally Effects**. If the FPS is high and stable, it gradually restores these settings. There's a cooldown period between adjustments to keep the experience smooth and prevent frequent changes.

4. **Combat Mode Settings**: During combat, **View Distance** is fixed to a level of 10, while **Sunlight Rays**, **Distortion**, and **Show Additional Ally Effects** continue to adjust dynamically based on FPS.

5.**Gradual View Distance Restoration**: After combat ends or low-FPS lock is released, the plugin restores view distance incrementally. Every 300 milliseconds, it checks the FPS. If the FPS is stable (above 44 FPS), it restores the next level of view distance. If FPS drops below the target, the process pauses or reverts to ensure smooth gameplay. Restoration happens gradually to maintain a balance between visual quality and performance.

6.**FSR Auto Adjustment**:

RAPO treats FSR (FidelityFX Super Resolution) as a last-resort tool. It only starts touching FSR after cheaper options like view distance, sunlight rays, distortion, and additional ally effects have already been reduced and FPS is still not stable enough.

FSR changes are based on FPS behavior over a longer time window, not on a single spike or dip. When FPS stays below the target for a while and the usual graphics tweaks are no longer effective, RAPO will request a one-step FSR downgrade (for example, from Quality → Balanced, or Balanced → Performance). Each change is followed by a cooldown period, so the addon will not rapidly switch FSR modes just because FPS is hovering around the threshold.

If your FPS later stays comfortably above the target for an extended period and the game is not in combat or in a low-FPS lock, RAPO may cautiously upgrade FSR by one step again. This upgrade uses the same long-term window and cooldown logic and is deliberately conservative to avoid flickering or constant mode flipping.

To keep combat readable and predictable, FSR mode is never changed during combat. Any pending FSR adjustment is delayed until combat has ended and the situation has stabilized. Overall, the goal is to let FSR auto-adjust slowly and safely in the background, while the more visible graphics options handle most of the fast reactions to FPS changes.

### Why This Approach?

- **View Distance**: Has the most significant impact on performance and affects visual quality in certain scenes, so it's prioritized for adjustment.
- **Sunlight Rays** and **Distortion**: Both have a moderate impact on performance, but **Distortion** is more commonly seen in-game, so **Sunlight Rays** gets adjusted first.
- **Show Additional Ally Effects**: While it impacts performance, seeing your allies' skill effects is a great visual part of the game, so it's adjusted last to preserve this experience.

### Important Notes

- **Restart Game Required**: After enabling the addon first time, restart your game to ensure all settings are applied correctly.
- **Gradual Restoration**: If you notice the graphics locked at the lowest settings, give it some time. The addon will gradually restore quality as the FPS allows.
- **Addon Compatibility**: This addon minimizes conflicts with other addons, but using multiple performance-related addons may impact its effectiveness. It's best to use only one graphics optimization addon at a time.
- **ROG Ally Settings**: For best results, set the power to 25–30 watts. This addon is also compatible with the ROG Ally X.

### Code references

Votan's Advanced Settings

Votan's Adaptive (Video-)Settings

Thanks Votan.

------------------------------------------

### Why Lock to 45 FPS?

You might be wondering, why lock the frame rate at 45 FPS instead of 60 FPS? Let me break it down in simple terms.

First, let's talk about why games tend to stutter or feel laggy when under heavy load. This usually happens because the hardware struggles to keep the frame times stable. For instance, at a 60 FPS limit, the frame time is 1/60 = 0.01667 seconds. If your hardware can consistently render and output each frame at this rate, the game will be smooth and stable, providing a great experience. However, if the hardware is pushed to its limits, the frame time can fluctuate—for example, one frame takes 0.01667 seconds, but the next might take 0.22 seconds, causing noticeable stuttering. Also, because your in-game actions rely on how quickly frames are rendered and shown on the screen, this instability in frame time makes the controls feel sluggish or unresponsive.

Given the hardware limitations of the ROG Ally, after plenty of testing and tweaking, I found that capping the frame rate at 45 FPS strikes the best balance between smooth gameplay and good visuals.


### What Are the Performance Bottlenecks of ROG Ally?

While the ROG Ally is the most powerful x86 gaming handheld currently available, it still can't match the performance of desktops or laptops with dedicated graphics cards. The main bottlenecks come from its screen and the SoC—specifically, the Ryzen Z1 Extreme.

1. Screen Bottleneck:
The ROG Ally’s 1080p screen is demanding for the Ryzen Z1 Extreme. Rendering games at this resolution and maintaining 60 FPS is tough for the chip without some help from technologies like FSR (FidelityFX Super Resolution).

2. Power Consumption Bottleneck:
Games need both the CPU and GPU to work together, and they share a limited power budget. If the GPU has to do too much rendering, it consumes more power, leaving less for the CPU. This can lead to performance drops in some scenarios when the CPU can’t keep up, causing stutters.

3. Bandwidth Bottleneck:
The Ryzen Z1 Extreme is an APU, meaning the CPU and GPU share the system memory, which is LPDDR5x. Unlike GDDR6 found on dedicated GPUs, the memory bandwidth here is much lower, creating a bottleneck. Additionally, the ROG Ally has only 16GB of RAM, with 4GB allocated to the GPU, leaving only 12GB for the system, which could lead to constant swapping to page files and make the bottleneck even worse.

4. Thermal Bottleneck:
As a handheld device, finding the right balance between SoC power, temperature, and fan noise is crucial. After experimenting with different strategies, setting the SoC power to 30 watts seemed to provide the best balance. However, even at 30W, maintaining a stable 60 FPS is difficult, which is why capping it at 45 FPS is a better choice for smoother gameplay.
