This is a generic script to move things from `lxplus` to another host via local machine as hop. Because lxplus sometimes block your access from this host (RIP UC Machines). 

### Key Features:

- **Required Arguments**:
  - `--source` - The source path on CERN server
  - `--dest` - The destination path on your university server
  - `--server` - University server hostname or SSH config name

- **Optional Arguments**:
  - `--cern-user` - CERN username (defaults to your local username)
  - `--cern-host` - CERN hostname (defaults to lxplus.cern.ch)
  - `--uni-user` - University username (defaults to your local username)
  - `--temp-dir` - Local temporary directory (defaults to "./transfer_temp")
  - `--pattern` - File pattern to transfer (defaults to "*.root")
  - `--dry-run` - Test mode without actual file transfers
  - `--help` - Show usage information

### Example Usage:

For your specific case:
```bash
./transfer.sh --source /eos/lhcb/wg/BnoC/Bu2LambdaPPP/MC/PIDCorrection \
              --dest /share/lazy/BnoC/Bu2LambdaPPP/rootfiles/MC/PIDCorrection \
              --server sleepy-earth
```

For a dry run:
```bash
./transfer.sh --source /eos/lhcb/wg/BnoC/Bu2LambdaPPP/MC/PIDCorrection \
              --dest /share/lazy/BnoC/Bu2LambdaPPP/rootfiles/MC/PIDCorrection \
              --server sleepy-earth \
              --dry-run
```

With all optional parameters:
```bash
./transfer.sh --source /path/on/cern \
              --dest /path/on/university \
              --server uni-server \
              --cern-user cernuser \
              --cern-host othercernhost.cern.ch \
              --uni-user uniuser \
              --temp-dir ./my_temp \
              --pattern "*.hdf5"

