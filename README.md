# Unraid User Scripts

This repository contains a collection of scripts designed to enhance the functionality of Unraid servers. These scripts cover a range of purposes, from hardware configuration to system management. Each script is detailed below with its purpose, usage instructions, and any necessary warnings or prerequisites.

## Table of Contents

- [GPU Resize Bar Passthrough Configuration](#gpu-resize-bar-passthrough-configuration)
- [Adding More Scripts](#adding-more-scripts)

---

## GPU Resize Bar Passthrough Configuration

### Description

This script configures the GPU's resize bar setting for passthrough in virtualized environments on Unraid systems. It supports both NVIDIA and AMD GPUs, adjusting the resize bar (rebar) settings based on the GPU's VRAM size. This adjustment is crucial for optimizing performance in VMs that utilize GPU passthrough.

### Usage

1. **Set User Variables:** Modify the variables at the beginning of the script to match your GPU's specifications:
   - `GPU`: The PCI address of your GPU.
   - `GPU_ID`: The identifier used for re-binding the GPU.
   - `VRAM_SIZE`: The amount of VRAM your GPU has, specified as a string (e.g., "16GB").

2. **Run the Script:** Add the script to user scripts in unRAID and ensure its set to run on Array Start. Ensure that you have enabled ReSizeBAR and Above 4G decode in the bios before running this script

3. **Verify Changes:** After running the script, verify that the changes have been applied correctly and that your virtualized environment recognizes the new settings. in unRAID you can check this by opening the console and using the GPU addres (it looks like 0a:00.0 )

```bash
   lspci -vvv 0a:00.0 | grep "BAR"
   ```
This will return the current values, it should match your GPU ram you.

### Troubleshooting

- If you encounter write errors or the script fails to apply settings, ensure that your VRAM size variable (`VRAM_SIZE`) is correct and that your GPU supports the specified configurations.
- In some cases you may need to set the VRAM size variable to be lower than your actual vram, this will just set the resizebar to be less than the vram.
- Check the system logs using `dmesg` for detailed error messages that can help in diagnosing issues.

---
