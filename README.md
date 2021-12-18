# Usefull Powershell snippets
#### ConnectionsWithProcessName
- Show processes connections filtering by their name or names,
    understands wildcards, saves to excel with ImportExcel
- By default does not resolves DN, and does not provide latency, enabled with
    -DoGetHost and -DoPing switch parameters e.g.:
    ```powershell
    .\ConnectionsWithProcessName.ps1 -DoGetHost -DoPing *fox,*earch*
    ```
