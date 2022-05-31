# Mentalab-EEGLab-Plugin

The Mentalab EEGLab Plugin is a MATLAB library that acts as a plugin for [EEGLab](https://sccn.ucsd.edu/eeglab/index.php). Use it to import Mentalab Explore CSV and BIN files into an EEGLab structure. 

**Please update to the latest version of EEGLab.**

## Installation

To install the Mentalab EEGLab plugin, use EEGLab's Extension Manager.

### Install via Extension Manager
Begin a new EEGLAB session and visit the Extension Manager under `File > Manage EEGLAB extensions`. The plugin is called _Mentalab_. You will only have to do this once.

### Install manually
The Mentalab EEGLAB plugin can also be installed manually. To do this, clone or download this repository directly from GitHub. Unzip the package and move the folder _mentalab-explore_ into the EEGLab _plugins_ folder.

## Usage
To use the Mentalab EEGLAB plugin, begin a new EEGLab session and select `Import Mentalab Explore data`, under `File > Import Data > Using EEGLAB functions and plugins`.

Your file manager will display only CSV and BIN files. Navigate to the file you wish to import, select, and open. You will be asked to name each ExG channel. If this is not important to you, select OK to continue.

### Importing CSV files 
If you are importing a CSV file, ensure that the current directory contains three files called:
* \<FILENAME\>_\_**ExG.csv**_
* \<FILENAME\>_\_**ORN.csv**_
* \<FILENAME\>_\_**Marker.csv**_. 

That is, each file should have the same name, but one should have suffix _\_ExG_, one should have suffix _\_ORN_, and the other _\_Marker_. These files should hold ExG, motion, and marker data respectively. 

If one of these files is not present, the plugin will not work. Your Mentalab Explore device will always record data for these three files. 

### Selecting ExG or Motion data
The Mentalab EEGLab plugin will always import ExG _and_ motion data, regardless of which file you select. 

For instance, if you select motion data _myData_ORN.csv_ in your File Explorer, the ExG data _myData_ExG.csv_ will also import. Both motion and ExG data will have markers linked to them. 

To select your dataset (ExG.csv or ORN.csv), navigate to the EEGLab drop-down menu _Datasets_.

## Contributing
Pull requests and feedback are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GNU General Public License v3.0](https://github.com/Nujanauss/Mentalab-EEGLab-Plugin/blob/master/LICENSE)
