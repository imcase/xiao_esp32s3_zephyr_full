# Project Rules

## Critical Rule: NEVER Overwrite Zephyr Original Files

### Rule 1: Zephyr Source Tree Protection
**NEVER overwrite any files or folders in the Zephyr source tree (`zephyr/` directory).**

**Rationale:**
- Zephyr is a managed repository that gets updated via `west update`
- Overwriting original files causes conflicts during updates
- Original files may be restored during west operations, losing custom changes
- Build system caching can cause persistent issues with overwritten files

### Rule 2: Custom File Integration Strategy
**Use one of these approaches instead of overwriting:**

1. **Custom Overlays**: Create separate `.overlay` files that get applied during build
2. **Kconfig Fragments**: Use separate `.conf` files for custom configurations
3. **Custom Sample Applications**: Create new sample directories with your custom files
4. **Build Script Integration**: Copy files to temporary locations during build process

### Rule 3: Build Script Requirements
**All build scripts must:**
- Check if target files exist before copying
- Use `safe_copy` function that prevents overwriting existing files
- Log warnings when attempting to overwrite files
- Only copy files to locations that don't conflict with Zephyr originals

### Rule 4: File Organization
**Custom files should be organized as:**
```
projects/xiao_esp32s3_zephyr_full/
├── drivers/          # Custom drivers (copied during build)
├── dts/             # Custom device tree bindings
├── boards/          # Custom board overlays
├── scripts/         # Build scripts
└── samples/         # Custom sample applications
```

### Rule 5: Build Process
**The build process should:**
1. Copy custom files to Zephyr tree only if they don't exist
2. Use separate overlay files instead of modifying existing ones
3. Create custom sample applications instead of modifying existing ones
4. Use Kconfig fragments instead of modifying main Kconfig files

### Rule 6: Version Control
**Never commit changes to:**
- `zephyr/` directory (managed by west)
- Any files that would overwrite Zephyr originals
- Build artifacts or temporary files

### Rule 7: Troubleshooting
**If you encounter issues:**
1. Check if any files are being overwritten
2. Use `git status` to see if Zephyr files are modified
3. Run `west update` to restore original Zephyr files
4. Reapply custom files using the safe copy approach

---
*This rule is critical for maintaining a stable development environment and preventing conflicts during Zephyr updates.* 