
# Minipro IC Identifier
A command-line tool designed to identify logic ICs using Minipro compatible programmers.

<div align="center">
![Using Minipro IC Identifier](images/capture_usage.png)
</div>

## Features
- Tests ICs by comparing their behavior against the definitions in the `logicic.xml` file from Minipro.
- Identifies multiple potential matches.
- Supports debugging mode to display detailed test output.

## Prerequisites

### Software Requirements
1. **Minipro**: The Minipro programmer software for testing ICs.
   - Install from your package manager or follow the installation guide at [Minipro GitLab](https://gitlab.com/DavidGriffith/minipro).

2. **xmllint**: A command-line XML processor used to parse the `logicic.xml` file.
   - Install using:
     - Debian/Ubuntu: `sudo apt install libxml2-utils`
     - Fedora: `sudo dnf install libxml2`
     - macOS (Homebrew): `brew install libxml2`

### Hardware Requirements
- **Minipro Programmer**: A Minipro supported programmer like the TL866 series.
- **IC**: Whatever chip you want to test/identify.

## Usage

### Clone the Repository
```bash
git clone https://github.com/gstrike/minipro_id_logic.git
cd minipro_id_logic
```

### Run the Script
```bash
./minipro_id_logic.sh --pins <PIN_COUNT> [--debug]
```

### Parameters
- `--pins <PIN_COUNT>`: Specify the number of pins on the IC. This parameter is required.
- `--debug`: Enable debug mode to display detailed test output.

### Examples
#### Basic Identification
Identify an IC with 14 pins:
```bash
./minipro_id_logic.sh --pins 14
```

#### Debugging Mode
Enable debugging mode to view detailed output:
```bash
./minipro_id_logic.sh --pins 14 --debug
```

### Expected Output
#### Single Match
```plaintext
$ ./minipro_id_logic.sh --pins 16
Minipro IC Identifier v0.1
Licensed under the MIT License - (c)2024 Gregory Strike

Testing ICs with 16 pins:
Testing chips [ 43%]
Potential match: 74109

Testing chips [100%]
Single match found: 74109
```

#### Multiple Matches
```plaintext
$ ./minipro_id_logic.sh --pins 16
Minipro IC Identifier v0.1
Licensed under the MIT License - (c)2024 Gregory Strike

Testing ICs with 16 pins:
Testing chips [ 42%]
Potential match: 4556

Testing chips [ 48%]
Potential match: 74139

Testing chips [100%]
Multiple matches found:
4556
74139
```

#### No Matches
```plaintext
$ ./minipro_id_logic.sh --pins 20
Minipro IC Identifier v0.1
Licensed under the MIT License - (c)2024 Gregory Strike

Testing ICs with 20 pins:
Testing chips [100%]
No matching chip found.
```

## Some Important Notes
To successfully identify a chip, it must pass the Minipro tests defined in the Minipro software. However, there are cases where the same tests may match multiple chips. This likely occurs because the tests in the logicic.xml file are designed to verify functionality rather than uniquely identify chips. If this becomes an issue, you can modify the logicic.xml file by adding additional test vectors to improve identification accuracy.

It's also worth noting that the logicic.xml file does not include every chip. Adding a new chip is straightforward—simply add the necessary definitions to the XML file.

## Disclaimer
This script is provided "as-is" and without warranty. The author is not responsible for any damage caused to ICs, hardware, or other devices as a result of using this script. Use at your own risk.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request with your improvements or bug fixes.
