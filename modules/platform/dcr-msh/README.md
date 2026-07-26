# dcr-msh

Multisession Azure Monitor Agent data collection for the VDI platform.

Ports legacy `vdi_dcr.bicep` / `vdi_customtables.bicep`:

- Data collection endpoint `uks-{env}-vdi-avd-dce-mult-all`
- Main Windows rule (performance + events)
- VM Insights rule
- FSLogix profile custom log → `multfslp_CL`
- Symantec WSS Agent custom log → `WSS_CL`

**Associations to virtual machines are not created here** — session-host deploy / PowerShell owns those.
