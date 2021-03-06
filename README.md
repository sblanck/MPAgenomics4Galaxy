# MPAgenomics4Galaxy (Documentation in progress)

MPAgenomics4galaxy is an integration of the R package [MPAgenomics](https://github.com/sblanck/MPAgenomics) and its dependencies within the galaxy platform.

[MPAgenomics](https://github.com/sblanck/MPAgenomics), standing for multi-patient analysis (MPA) of genomic markers, is an R-package devoted to:

  * Efficient segmentation
  * Selection of genomic markers from multi-patient copy number and SNP data profiles. 

The segmentation of successive multiple profiles (finding losses and gains) is performed with an automatic choice of parameters. Considering multiple profiles in the same time, MPAgenomics wraps efficient penalized regression methods to select relevant markers associated with a given outcome.

This Galaxy integration of MPAgenomics (MPAgenomics4Galaxy) offers a simplified use of the R package through the Galaxy interface, for users who are not familiar with the R language.

Moreover, the use of docker images to package the dependencies makes it easy to deploy the package either within an existing Galaxy instance or on a simple personal computer.


## Table of contents

- [Overview of MPAgenomics4Galaxy](#overview-of-mpagenomics4galaxy)
- [How to install MPAgenomics4Galaxy](#how-to-install-mpagenomics4galaxy)
    - [From the galaxy toolshed](#from-the-galaxy-toolshed)
    - [From a full dockerized Galaxy instance](#from-a-full-dockerized-galaxy-instance)
- [How to use MPAgenomics4Galaxy](#how-to-use-mpagenomics4galaxy)
    - [Get data](#get-data)
        - [Upload data to Galaxy](#upload-data-to-galaxy)
    - [Preprocess and normalization](#preprocess-and-normalization)
    - [Extract signal](#extract-signal)
    - [Segmentation and Calling of an extracted signal](#segmentation-and-calling-of-an-extracted-signal)
    - [Filtering](#filtering)
    - [Markers selection](#markers-selection)

## Overview of MPAgenomics4Galaxy

The features of MPAgenomics4galaxy are as follows :

The different tools present in MPAgenomics4galaxy are the following ones and are linked as shown in the diagram below :

- [Preprocess and normalization](#preprocess-and-normalization)
- [Signal Extraction of Copy number or Allele B Fraction](#extract-signal)
- [Segmentation and calling](#segmentation-and-calling-of-an-extracted-signal)
- [Filtering](#filtering)
- [Markers selection](#markers-selection)

![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/mpagenomics4Galaxy.png)

## How to install MPAgenomics4Galaxy

### From the galaxy toolshed
         
If you are an administrator of a Galaxy instance, you can install          [MPAgenomics4Galaxy from the Galaxy toolshed](https://toolshed.g2.bx.psu.edu/view/sblanck/mpagenomics)

As MPAgenomics4Galaxy uses docker to manage its dependencies, you have to configure Galaxy to run jobs in docker containers as explained in [Galaxy documentation](https://docs.galaxyproject.org/en/latest/admin/jobs.html#running-jobs-in-containers)

### From a full dockerized Galaxy instance
                            
A full dockerized version of Galaxy containing MPAgenomics, based on [bgruening galaxy-stable](https://github.com/bgruening/docker-galaxy-stable) is also available.
                          
 At first you need to install Docker. Please follow the [very good instructions](https://docs.docker.com/installation/) from the Docker project.
                          
After the successful installation, all you need to do is:
                            
```
docker run -d -p 8080:80 -p 8021:21 -p 8022:22 sblanck/galaxy-mpagenomics
```
                          
If you already have run galaxy-mpagenomics with docker and want to fetch the last docker image of galaxy-mpagenomics, type 
                          
```
docker pull sblanck/galaxy-mpagenomics
docker run -d -p 8080:80 -p 8021:21 -p 8022:22 sblanck/galaxy-mpagenomics
```
                          
Then, you just need to open a web browser (chrome or firefox are recommanded) and type 
```
localhost:8080
```
into the adress bar to access Galaxy running MPAgenomics.
                          
The Galaxy Admin User has the username `admin@galaxy.org` and the password `password`. In order to use some features of Galaxy, like import history, one has to be logged in with this username and password.
                          
Docker images are "read-only", all your changes inside one session will be lost after restart. This mode is useful to present Galaxy to your colleagues or to run workshops with it. To install Tool Shed repositories or to save your data you need to export the calculated data to the host computer.
                          
Fortunately, this is as easy as:
```
docker run -d -p 8080:80 \
-v /home/user/galaxy_storage/:/export/ \
sblanck/galaxy-mpagenomics
```
                          
                          
For more information about the parameters and docker usage, please refer to https://github.com/bgruening/docker-galaxy-stable/blob/master/README.md#Usage
                      
                      
## How to use MPAgenomics4Galaxy 

### Get data
                              
This introductory example aims at helping the user understand the main functions of MPAgenomics.
                            
The example is based on a data-set containing 8 CEL Files (4 tumor files and 4 matching normal files) which can be downloaded [here](https://nextcloud.univ-lille.fr/index.php/s/i9edeAWWLwYxTsf/download), in a zip file. These files are extracted from GEO dataset [GSE80460](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE80460)
                            
An other zip file containing annotation files (.cdf, ufl, ugp and acs annotation files) for the Affymetrix GenomeWide SNP6 platform  is available [here](https://nextcloud.univ-lille.fr/index.php/s/68NEXB9TwTnfEs2)

You also need the normal-tumor .csv file available [here](https://github.com/sblanck/MPAgenomics4Galaxy/blob/master/data/normaltumorSNP6.csv) (Right click on the "raw" button and save link as)

And the response .csv file avalaible [here](https://github.com/sblanck/MPAgenomics4Galaxy/blob/master/data/responseSNP6.csv) (Right click on the "raw" button and save link as)
                            
#### Upload data on Galaxy
                            
First you have to unzip the 2 zip files previously downloaded. 
                            
Then upload the 8 .CEL files with the galaxy upload tool. Be careful to choose the correct datatype (.cel) with the upload tool as galaxy may not auto-detect .CEL files.
                            
You also need to upload the four annotation files. Here again, you need to specify the file type for each annotation file  (.cdf, .ufl, .ugp, .acs) as galaxy may not auto-detect them.

Finally, upload the 2 .csv files (normal-tumor file and response file)
                            
                            
### Preprocess and normalization
                            
This preprocessing step consists in a correction of biological and technical biaises due to the experiment. Raw data from Affymetrix arrays are provided in different CEL files. These data must be normalized before statistical analysis. The pre-processing is proposed as a wrapper of aroma packages (using CRMAv2 and TumorBoost when appropriate). Note that this implies that the pre-processing step is only available for Affymetrix arrays.
                            
> :warning: **This step may take several hours**

![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalization.png)
                            ![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalization2.png)
                            
This step is done with the Data normalization tool which have the following inputs :
  * A dataset name
  * A list of .CEL files
  * The 4 chip annotations files (.cdf, ufl, ugp, acs)
  * An optionnal csv file in a case of a normal-tumor study with tumor boost
                            
In cases where normal (control) samples match to tumor samples, normalization can be improved using TumorBoost. In this case, a normal-tumor csv file must be provided :
                            
  * The first column contains the names of the files corresponding to normal samples of the dataset.
  * The second column contains the names of the tumor samples files.
  * Column names of these two columns are respectively normal and tumor.
  * Columns are separated by a comma.
  * Extensions of the files (.CEL for example) should be removed
                            
  Example of a normal-tumor .csv file :
```
normal,tumor
GSM2127727_P1_N_SNP6,GSM2127658_P1_T1_SNP6
GSM2127728_P3_N_SNP6,GSM2127659_P3_T1_SNP6
GSM2127729_P5_N_SNP6,GSM2127660_P5_T1_SNP6
GSM2127730_P7_N_SNP6,GSM2127661_P7_T1_SNP6
```
                            
The outputs are 
 - A .dsf file, summarizing the data
 - An optionnal log files
 - A zip file containing the results of the normalization
 - An optionnal .zip file containing all the figures of the normalized data
                            
Here is an example of a .dsf file 
```
GSM2127658_P1_T1_SNP6.CEL	SNP6_example	GenomeWideSNP_6
GSM2127659_P3_T1_SNP6.CEL	SNP6_example	GenomeWideSNP_6
GSM2127727_P1_N_SNP6.CEL	SNP6_example	GenomeWideSNP_6
GSM2127728_P3_N_SNP6.CEL	SNP6_example	GenomeWideSNP_6
GSM2127660_P5_T1_SNP6.CEL	SNP6_example	GenomeWideSNP_6
GSM2127661_P7_T1_SNP6.CEL	SNP6_example	GenomeWideSNP_6
GSM2127729_P5_N_SNP6.CEL	SNP6_example	GenomeWideSNP_6
GSM2127730_P7_N_SNP6.CEL	SNP6_example	GenomeWideSNP_6
                           
```
* First column contains the name of the file
* Second column contains the name of the dataset
* Third column contains the chip type
                            
And here is an example of figures of normalized data :
                            
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalized_figures.png)
                            
### Extract signal
                            
This tool extracts the copy number or the allele B fraction profile from the normalized data.
                            
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/extract.png)
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/extract2.png)
                            
                            
The inputs of the *Extract* tool are the following ones :

  * A dataset summary file generated by the *Data normalization* tool
  * A zip file containing the results of the normalization step generated by the *Data normalization* tool
  * A file selection mode, to choose files to be extracted
  * Either the whole dataset or a selection of  few files
  * The chromosomes to be extracted
  * The type of signal to be extracted : 
    * CN : Copy Number
    * FracB : Allele B fraction
  * An optionnal .csv file in a case of a normal-tumor study 
                            
The outputs are :

  * a .sef (signal extraction files) containing the data extracted : 3 fixed columns and 1 column per sample:
    * chr: Chromosome.
    * position: Genomic position (in bp).
    * probeNames: Name of the probes of the microarray.
    * One column per sample which contains the signal values for each sample.
  * An optionnal log file.
                            
Example of the first lines of a .sef file :
                            
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/sef.png)

                  
### Segmentation and Calling of an extracted signal 


This tool segments normalized profiles provided by the user and labels segments found in the copy-number profiles.
                            
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/extract_prev2.png)
                            
*The Segmentation and Calling of a previously normalized data* tool have the following inputs :

  * a .sef (signal extraction files), copy number or Allele B fracion generated by the extract tool
  * The segmentation method (cghseg or PELT method)
  * The type of signal to be segmented
    * CN : Copy Number
    * FracB : Allele B fraction
  * The number of calling classes (CN signal only)
    * 3 calling classes (gain, normal, loss)
    * 4 calling classes (amplification, gain, normal, loss)
    * 5 calling classes (amplification, gain, normal, loss, double loss)
  * The cellularity (CN signal only) :ratio of tumor cells in the sample)
                            
The outputs are :

  * A .scr (segmentation and calling result) file containing 7 columns :
    * sampleNames: Names of the original .CEL files.
    * chrom: Chromosome of the segment.
    * chromStart: Starting position (in bp) of the segment. This position is not included in the segment.
    * chromEnd: Ending position (in bp) of the segment. This position is included in the segment.
    *  probes: Number of probes in the segment.
    *  means: Mean of the segment.
    *  calls: When input signal is copy number signal, calling of the segment (”double loss”, ”loss”, ”normal”, ”gain” or ”amplification”).
  * A zip file containing the figures of the segmentation
  * An optionnal log file

### Filtering

This tool filters results obtained by the *segmentation and calling* tool.
                            
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/filter.png)
                    
The *Filter* tool have the following inputs :
                            
  * A .scr file generated by the of the 2 *segmentation and calling* tool
  * The minimum length to keep in a segment
  * The minimum number of probes to keep in a segment
  * The calling labels to keep
                            
The outputs are :
  
  * A .scr (segmentation and calling result) file containing 7 columns :
    * sampleNames: Names of the original .CEL files.
    * chrom: Chromosome of the segment.
    * chromStart: Starting position (in bp) of the segment. This position is not included in the segment.
    * chromEnd: Ending position (in bp) of the segment. This position is included in the segment.
    * probes: Number of probes in the segment.
    * means: Mean of the segment.
    * calls: Calling of the segment (”double loss”, ”loss”, ”normal”, ”gain” or ”amplification”).
  * An optionnal log file

Head of an .scr output file : 
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/scrfile.png)
                            
### Markers selection


This tool selects some relevant markers from normalized signal matrix data, according to a response using penalized regressions.
                            
<!--If you want to run this example, you need first to upload the [response.csv](https://github.com/sblanck/MPAgenomics4Galaxy/blob/master/reponse.csv) file available on this github.-->
                            
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/selection_extract.png)
                            
The inputs are :

  * A .sef (signal extraction file) generated by the *Extract* tool
  * A response .csv file
  * The number of folds for cross validation (must be lower than the number of samples in the .sef file)
  * The response type : Linear or Logistic
                            
The outputs are:

A tabular text file containing 5 columns which describe all the selected probes (1 line per SNPs):

  * chr: Chromosome containing the selected probe.
  * position: Position of the selected probe.
  * index: Index of the selected probe.
  * names: Name of the selected probe.
  * coefficient: Regression coefficient of the selected probe.
                            
**Data Response csv file**
                            
Data response csv file format:

  * The first column contains the names of the different files of the data-set.
  * The second column contains the response associated with each file.
  * Column names of these two columns are respectively files and response.
  * Columns are separated by a comma
  * Extensions of the files (.CEL for example) should be removed
  
In the case of a normal-tumor study, only the .CEL files of the tumor samples should be included in the response file.
                            
**Example**
                            
With the 8 .cel files in the normal-tumor studied dataset

```                       
GSM2127658_P1_T1_SNP6.CEL
GSM2127659_P3_T1_SNP6.CEL
GSM2127727_P1_N_SNP6.CEL
GSM2127728_P3_N_SNP6.CEL
GSM2127660_P5_T1_SNP6.CEL
GSM2127661_P7_T1_SNP6.CEL
GSM2127729_P5_N_SNP6.CEL
GSM2127730_P7_N_SNP6.CEL
```

The csv file should look like this

```                            
files,response
GSM2127658_P1_T1_SNP6,2.113406
GSM2127659_P3_T1_SNP6,2.047897
GSM2127660_P5_T1_SNP6,2.385327
GSM2127661_P7_T1_SNP6,1.654766
```                        

Example of the output file of the *marker selection* tool
![](https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/selectionFile.png)
