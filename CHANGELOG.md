# CHANGELOG

## v1.0.0 - 2025-09-17

### 🎉 Initial Release

**Fibocom L850-GL WWAN Complete Installation Guide for Debian**

#### ✅ Features Implemented
- **Hardware Detection**: Automatic detection of Intel XMM7360 LTE modem
- **Driver Validation**: Support for iosm driver and WWAN port creation
- **ModemManager Integration**: Workarounds for RPC mode limitations
- **GUI Configuration**: Complete graphical interface setup (4 tools available)
- **Network Manager Integration**: Seamless connection like WiFi
- **Comprehensive Documentation**: Step-by-step guides and troubleshooting
- **Automated Scripts**: 6 specialized scripts for different scenarios

#### 🛠️ Scripts Provided
- `quick_connect.sh` - Initial verification and AT communication test
- `setup_gui.sh` - Complete GUI setup for graphical interface
- `diagnose_wwan.sh` - Complete system diagnostic
- `final_check.sh` - Post-installation verification (after SIM/antennas)
- `configure_modemmanager.sh` - Advanced ModemManager configuration
- `configure_direct_wwan.sh` - Low-level direct configuration

#### 📚 Documentation
- `setup_guide.md` - Complete step-by-step configuration guide
- `troubleshooting.md` - Technical analysis and solutions
- `gui_setup.md` - Graphical interface manual (4 GUI tools)
- `physical_installation.md` - SIM and antenna installation guide

#### 🎯 Problem Solved
**Issue**: Fibocom L850-GL (FRU# 01AX792) not recognized by ModemManager
**Root Cause**: ModemManager 1.24.0 doesn't fully support iosm driver RPC mode
**Solution**: Multiple approaches provided - GUI configuration, direct connection, and ModemManager workarounds

#### 🖥️ Tested Environment
- **Hardware**: Lenovo ThinkPad T480
- **OS**: Debian 13 Trixie
- **Kernel**: 6.12.43+ (iosm driver included)
- **ModemManager**: 1.24.0
- **Desktop**: GNOME with NetworkManager

#### 🏆 Results Achieved
✅ Hardware properly detected and functioning
✅ iosm driver loaded with WWAN ports created
✅ GUI tools installed and configured  
✅ NetworkManager connection ready
✅ Ready for SIM installation and immediate use
✅ Complete troubleshooting documentation

#### 🔄 Next Steps for Users
1. Install SIM card and antennas physically
2. Run `./scripts/final_check.sh`
3. Configure APN in Settings → Network → Mobile Broadband
4. Connect like WiFi!

---

## Future Versions

### Planned Improvements
- Support for ModemManager 1.26+ when available in Debian
- Additional hardware compatibility (other Fibocom models)
- Automated APN detection by carrier
- SMS functionality integration
- Data usage monitoring scripts

### Known Limitations
- ModemManager 1.24.0 RPC mode limitation (workaround provided)
- Manual APN configuration required
- Requires physical SIM installation