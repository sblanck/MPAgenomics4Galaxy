---


---

<h1 id="mpagenomics4galaxy">MPAgenomics4Galaxy</h1>
<p>MPAgenomics, standing for multi-patients analysis (MPA) of genomic markers, is an R-package devoted to: (i) efficient segmentation, and (ii) genomic marker selection from multi-patient copy number and SNP data profiles. It provides wrappers from commonly used packages to facilitate their repeated (sometimes difficult) use, offering an easy-to-use pipeline for beginners in R. The segmentation of successive multiple profiles (finding losses and gains) is based on a new automatic choice of influential parameters since default ones were misleading in the original packages. Considering multiple profiles in the same time, MPAgenomics wraps efficient penalized regression methods to select relevant markers associated with a given response.</p>
<ul>
<li><a href="#how-to-install-mpa">How to install MPAgenomics4Galaxy</a>
<ul>
<li><a href="#using-docker">Using docker</a></li>
<li><a href="#from-the-galaxy-toolshed">From the galaxy toolshed</a></li>
</ul>
</li>
<li><a href="#how-to-use-mpa">How to use MPAgenomics4Galaxy</a>
<ul>
<li><a href="#get-data">Get data</a></li>
<li><a href="#upload">Upload data to Galaxy</a></li>
<li><a href="#normalization">Preprocess and normalization</a></li>
<li><a href="seg-call">Segmentation and Calling of normalized data</a></li>
<li><a href="#extract">Extract Copy number signal</a></li>
<li><a href="#seg-call-extracted">Segmentation and Calling of a normalized signal matrix data</a></li>
<li><a href="#filtering">Filtering</a></li>
<li><a href="#markers-selection">Markers selection</a></li>
<li><a href="#markers-selection-extracted">Markers selection of a normalized signal matrix data</a></li>
</ul>
</li>
</ul>
<h2 id="how-to-install-mpagenomics4galaxy--a-namehow-to-install-mpa--toc">How to install MPAgenomics4Galaxy  <a> </a><a href="#toc">[toc]</a></h2>
<h3 id="using-docker--a-nameusing-docker--toc">Using Docker  <a> </a><a href="#toc">[toc]</a></h3>
<p>A dockerized version of Galaxy containing MPAgenomics, based on <a href="https://github.com/bgruening/docker-galaxy-stable">bgruening galaxy-stable</a> is also available.</p>
<p>At first you need to install Docker. Please follow the <a href="https://docs.docker.com/installation/">very good instructions</a> from the Docker project.</p>
<p>After the successful installation, all you need to do is:</p>
<pre><code>docker run -d -p 8080:80 -p 8021:21 -p 8022:22 sblanck/galaxy-mpagenomics
</code></pre>
<p>If you already have run galaxy-mpagenomics with docker and want to fetch the last docker image of galaxy-mpagenomics, type</p>
<pre><code>docker pull sblanck/galaxy-mpagenomics
docker run -d -p 8080:80 -p 8021:21 -p 8022:22 sblanck/galaxy-mpagenomics
</code></pre>
<p>Then, you just need to open a web browser (chrome or firefox are recommanded) and type</p>
<pre><code>localhost:8080
</code></pre>
<p>into the adress bar to access Galaxy running MPAgenomics.</p>
<p>The Galaxy Admin User has the username <code>admin@galaxy.org</code> and the password <code>admin</code>. In order to use some features of Galaxy, like import history, one has to be logged in with this username and password.</p>
<p>Docker images are “read-only”, all your changes inside one session will be lost after restart. This mode is useful to present Galaxy to your colleagues or to run workshops with it. To install Tool Shed repositories or to save your data you need to export the calculated data to the host computer.</p>
<p>Fortunately, this is as easy as:</p>
<pre><code>docker run -d -p 8080:80 \
    -v /home/user/galaxy_storage/:/export/ \
    sblanck/galaxy-mpagenomics
</code></pre>
<p>For more information about the parameters and docker usage, please refer to <a href="https://github.com/bgruening/docker-galaxy-stable/blob/master/README.md#Usage">https://github.com/bgruening/docker-galaxy-stable/blob/master/README.md#Usage</a></p>
<h3 id="from-the-galaxy-toolshed-a-namefrom-the-galaxy-toolshed--toc">From the galaxy toolshed <a> </a><a href="#toc">[toc]</a></h3>
<p><a href="https://toolshed.g2.bx.psu.edu/view/sblanck/mpagenomics/b3acec804ebc">MPAgenomics wrappers are available on the galaxy toolshed </a></p>
<p>You also have to install R dependencies. You will need a recent version on R (&gt;=3.6) .<br>
Then run the <a href="https://github.com/sblanck/MPAgenomics4Galaxy/blob/master/install.R">install.R</a> script available on this github :</p>
<pre><code>Rscript install.R
</code></pre>
<h2 id="how-to-use-mpagenomics4galaxy--a-namehow-to-use-mpa--toc">How to use MPAgenomics4Galaxy  <a> </a><a href="#toc">[toc]</a></h2>
<h3 id="get-data--a-namehow-to-use-mpa--toc">Get data  <a> </a><a href="#toc">[toc]</a></h3>
<p>This introductory example aims at helping the user understand the main functions of MPAgenomics.</p>
<p>The example is based on a free data-set containing 8 CEL Files which can be downloaded <a href="https://nextcloud.univ-lille.fr/index.php/s/93ga3eNAxeSHFdi">here</a>, in a zip file.</p>
<p>An other zip file containing annotation files (.cdf, ufl, ugp and acs annotation files) is available <a href="https://nextcloud.univ-lille.fr/index.php/s/68NEXB9TwTnfEs2">here</a></p>
<h3 id="upload-data-on-galaxy--a-nameupload--toc">Upload data on Galaxy  <a> </a><a href="#toc">[toc]</a></h3>
<p>First you have to unzip the 2 zip files previously downloaded.</p>
<p>Then upload the 8 .CEL files with the galaxy upload tool. Be careful to choose the correct datatype (.cel) with the upload tool as galaxy doesn’t auto-detect .CEL files.</p>
<p>You also need to upload the four annotation files. Here again, you need to specify the file type for each annotation file  (.cdf, .ufl, .ugp, .acs) as galaxy does not auto-detect them.</p>
<h3 id="preprocess-and-normalization--a-namenormalization--toc">Preprocess and normalization  <a> </a><a href="#toc">[toc]</a></h3>
<p>This preprocessing step consists in a correction of biological and technical biaises due to the experiment. Raw data from Affymetrix arrays are provided in different CEL files. These data must be normalized before statistical analysis. The pre-processing is proposed as a wrapper of aroma packages (using CRMAv2 and TumorBoost when appropriate). Note that this implies that the pre-processing step is only available for Affymetrix arrays.</p>
<blockquote>
<p>⚠️ <strong>This step may take several hours</strong></p>
</blockquote>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalization.png" alt="normalization"><br>
<img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalization2.png" alt="normalization"></p>
<p>This step is done with the Data normalization tool which have the following inputs :</p>
<ul>
<li>A dataset name</li>
<li>A list of .CEL files</li>
<li>The 4 chip annotations files (.cdf, ufl, ugp, acs)</li>
<li>An optionnal csv file in a case of a normal-tumor study with tumor boost</li>
</ul>
<p>Chip annotations filenames must strictly follow the following rules :</p>
<ul>
<li><em>.cdf</em> filename must comply with the following format : &lt; chiptype &gt;,&lt; tag &gt;.cdf (e.g, for a GenomeWideSNP_6 chip: GenomeWideSNP_6,Full.cdf). Note the use of a comma (not a point) between  and the tag “Full”.</li>
<li><em>.ufl</em> filename must start with &lt; chiptype &gt;,&lt; tag &gt; (e.g, for a GenomeWideSNP_6 chip: GenomeWideSNP_6,Full,na31,hg19,HB20110328.ufl).</li>
<li><em>.ugp</em> filename must start with &lt; chiptype &gt;,&lt; tag &gt; (e.g, for a GenomeWideSNP_6 chip: GenomeWideSNP_6,Full,na31,hg19,HB20110328.ugp).</li>
<li><em>.acs</em> file name must start with &lt; chiptype &gt;,&lt; tag &gt; (e.g, for a GenomeWideSNP_6 chip: GenomeWideSNP_6,HB20080710.acs).</li>
</ul>
<p>In cases where normal (control) samples match to tumor samples, normalization can be improved using TumorBoost. In this case, a normal-tumor csv file must be provided :</p>
<ul>
<li>The first column contains the names of the files corresponding to normal samples of the dataset.</li>
<li>The second column contains the names of the tumor samples files.</li>
<li>Column names of these two columns are respectively normal and tumor.</li>
<li>Columns are separated by a comma.</li>
<li>Extensions of the files (.CEL for example) should be removed</li>
</ul>
<p>Example of a normal-tumor .csv file :</p>
<pre><code>normal,tumor
patient1_normal,patient1_tumor
patient2_normal,patient2_tumor
patient3_normal,patient3_tumor
</code></pre>
<p>The outputs are</p>
<ul>
<li>A .dsf file, summarizing the data</li>
<li>An optionnal log files</li>
<li>An optionnal .zip file containing all the figures of the normalized data</li>
</ul>
<p>Here is an example of a .dsf file</p>
<pre><code>GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A08_31330.CEL	Example	GenomeWideSNP_6
GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A07_31314.CEL	Example	GenomeWideSNP_6
GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A06_31298.CEL	Example	GenomeWideSNP_6
GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A05_31282.CEL	Example	GenomeWideSNP_6
GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A04_31266.CEL	Example	GenomeWideSNP_6
GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A03_31250.CEL	Example	GenomeWideSNP_6
GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A02_31234.CEL	Example	GenomeWideSNP_6
GIGAS_g_GAINmixHapMapAffy2_GenomeWideEx_6_A01_31218.CEL	Example	GenomeWideSNP_6
</code></pre>
<ul>
<li>First column contains the name of the file</li>
<li>Second column contains the name of the dataset</li>
<li>Third column contains the chip type</li>
</ul>
<p>And here is an example of figures of normalized data :</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalized_figures.png" alt="enter image description here"></p>
<h3 id="segmentation-and-calling-of-normalized-data--a-nameseg-call--toc">Segmentation and Calling of normalized data  <a> </a><a href="#toc">[toc]</a></h3>
<p>This tool segments the previously normalized profiles and labels segments found in the copy-number profiles.</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/segcall.png" alt="enter image description here"><br>
<img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/segcall2.png" alt="enter image description here"></p>
<p><em>The Segmentation and Calling of normalized data</em> tool have the following inputs :</p>
<ul>
<li>A dataset summary file generated by the <em>Data normalization</em> tool</li>
<li>A file selection mode, to choose files to be segmented
<ul>
<li>Either the whole dataset</li>
<li>Or a selection of  few files</li>
</ul>
</li>
<li>An optionnal tumor-control reference .csv files</li>
<li>The chromosomes to be processed</li>
<li>The segmentation method (cghseq or PELT method)</li>
<li>The number of calling classes
<ul>
<li>3 calling classes (gain, normal, loss)</li>
<li>4 calling classes (amplification, gain, normal, loss)</li>
<li>5 calling classes (amplification, gain, normal, loss, double loss)</li>
</ul>
</li>
<li>The cellularity (ratio of tumor cells in the sample)</li>
</ul>
<p>The outputs are :</p>
<ul>
<li>A .scr (segmentation and calling result) file containing 7 columns :
<ul>
<li>sampleNames: Names of the original .CEL files.</li>
<li>chrom: Chromosome of the segment.</li>
<li>chromStart: Starting position (in bp) of the segment. This position is not included in the segment.</li>
<li>chromEnd: Ending position (in bp) of the segment. This position is included in the segment.</li>
<li>probes: Number of probes in the segment.</li>
<li>means: Mean of the segment.</li>
<li>calls: Calling of the segment (”double loss”, ”loss”, ”normal”, ”gain” or ”amplification”).</li>
</ul>
</li>
<li>An optionnal .zip files containing the figures of the segmentation</li>
<li>An optionnal log file</li>
</ul>
<p>Here is an example of a .scr file :</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/scr.png" alt="example of an scr file"></p>
<p>And a example of a figure of a segmented chromosome:</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/segchr17.png" alt="Example of a figure"></p>
<h3 id="extract--a-nameextract--toc">Extract  <a> </a><a href="#toc">[toc]</a></h3>
<p>This tool extracts the copy number or the allele B fraction profile from the normalized data.</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/extractbis.png" alt="enter image description here"></p>
<p>The inputs of the <em>Extract</em> tool are the following ones :</p>
<ul>
<li>A dataset summary file generated by the <em>Data normalization</em> tool</li>
<li>A file selection mode, to choose files to be extracted
<ul>
<li>Either the whole dataset</li>
<li>Or a selection of  few files</li>
</ul>
</li>
<li>The chromosomes to be extracted</li>
<li>The type of signal to be extracted :
<ul>
<li>CN : Copy Number</li>
<li>FracB : Allele B fraction</li>
</ul>
</li>
<li>An optionnal .csv file in a case of a normal-tumor study</li>
</ul>
<p>The outputs are:</p>
<ul>
<li>
<p>a .sef (signal extraction files) containing the data extracted : 3 fixed columns and 1 column per sample:</p>
<ul>
<li>chr: Chromosome.</li>
<li>position: Genomic position (in bp).</li>
<li>probeNames: Name of the probes of the microarray.</li>
<li>One column per sample which contains the copy number profile for each sample.</li>
</ul>
</li>
<li>
<p>An optionnal log file.</p>
</li>
</ul>
<p>Example of the first lines of a .sef file :</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/sef.png" alt="enter image description here"></p>
<h3 id="segmentation-and-calling-of-a-normalized-signal--matrix-data-a-nameseg-call-extracted--toc">Segmentation and Calling of a normalized signal  matrix data <a> </a><a href="#toc">[toc]</a></h3>
<p>This tool segments normalized profiles provided by the user and labels segments found in the copy-number profiles.</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/extract_prev2.png" alt="enter image description here"><br>
<em>The Segmentation and Calling of a previously normalized data</em> tool have the following inputs :</p>
<ul>
<li>a .sef (signal extraction files) generated by the extract tool</li>
<li>The segmentation method (cghseq or PELT method)</li>
<li>The type of signal to be segmented
<ul>
<li>CN : Copy Number</li>
<li>FracB : Allele B fraction</li>
</ul>
</li>
<li>An optionnal tumor-control reference .csv files</li>
<li>The number of calling classes
<ul>
<li>3 calling classes (gain, normal, loss)</li>
<li>4 calling classes (amplification, gain, normal, loss)</li>
<li>5 calling classes (amplification, gain, normal, loss, double loss)</li>
</ul>
</li>
<li>The cellularity (ratio of tumor cells in the sample)</li>
</ul>
<p>The outputs are :</p>
<ul>
<li>A .scr (segmentation and calling result) file containing 7 columns :
<ul>
<li>sampleNames: Names of the original .CEL files.</li>
<li>chrom: Chromosome of the segment.</li>
<li>chromStart: Starting position (in bp) of the segment. This position is not included in the segment.</li>
<li>chromEnd: Ending position (in bp) of the segment. This position is included in the segment.</li>
<li>probes: Number of probes in the segment.</li>
<li>means: Mean of the segment.</li>
<li>calls: Calling of the segment (”double loss”, ”loss”, ”normal”, ”gain” or ”amplification”).</li>
</ul>
</li>
<li>An pdf file containing the figures of the segmentation</li>
<li>An optionnal log file</li>
</ul>
<h3 id="filtering--a-namefiltering--toc">Filtering  <a> </a><a href="#toc">[toc]</a></h3>
<p>This tool filters results obtained by the segmentation and calling tool.</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/filter.png" alt="enter image description here"></p>
<p>The <em>Filter</em> tool have the following inputs :</p>
<ul>
<li>A .scr file generated by the of the 2 <em>segmentation and calling</em> tool</li>
<li>The minimum length to keep in a segment</li>
<li>The minimum number of probes to keep in a segment</li>
<li>The calling labels to keep</li>
</ul>
<p>The outputs are :</p>
<ul>
<li>A .scr (segmentation and calling result) file containing 7 columns :
<ul>
<li>sampleNames: Names of the original .CEL files.</li>
<li>chrom: Chromosome of the segment.</li>
<li>chromStart: Starting position (in bp) of the segment. This position is not included in the segment.</li>
<li>chromEnd: Ending position (in bp) of the segment. This position is included in the segment.</li>
<li>probes: Number of probes in the segment.</li>
<li>means: Mean of the segment.</li>
<li>calls: Calling of the segment (”double loss”, ”loss”, ”normal”, ”gain” or ”amplification”).</li>
</ul>
</li>
<li>An optionnal log file</li>
</ul>
<h3 id="markers-selection--a-namemarkers-selection--toc">Markers selection  <a> </a><a href="#toc">[toc]</a></h3>
<p>This tool selects some relevant markers from previously preprocessed .CEL files, according to a response using penalized regressions.</p>
<p>If you want to run this example, you need first to upload the <a href="https://github.com/sblanck/MPAgenomics4Galaxy/blob/master/reponse.csv">response.csv</a> file available on this github.</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/Selection1.png" alt="Marker Selection"><br>
<img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/Selection2.png" alt="Marker Selection"></p>
<p>The inputs are :</p>
<ul>
<li>A dataset summary file generated by the <em>Data normalization</em> tool</li>
<li>A response .csv file</li>
<li>The signal you want to work on : copy number (CN) or allele B fraction (fracB)</li>
<li>An optionnal normal-tumor csv file</li>
<li>The number of folds for cross validation (must be lower than the number of samples)</li>
<li>The response type : Linear or Logistic</li>
<li>The R package used to select relevant markers : HDPenReg or spikslab (for linear reponse only)</li>
</ul>
<p>The outputs are:</p>
<p>A tabular text file containing 5 columns which describe all the selected SNPs (1 line per SNPs):</p>
<ul>
<li>chr: Chromosome containing the selected SNP.</li>
<li>position: Position of the selected SNP.</li>
<li>index: Index of the selected SNP.</li>
<li>names: Name of the selected SNP.</li>
<li>coefficient: Regression coefficient of the selected SNP.</li>
</ul>
<p>This is an example of the output file :<br>
<img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/selection_results.png" alt="Marker Selection"></p>
<p><strong>Data Response csv file</strong></p>
<p>Data response csv file format:</p>
<ul>
<li>The first column contains the names of the different files of the data-set.</li>
<li>The second column contains the response associated with each file.</li>
<li>Column names of these two columns are respectively files and response.</li>
<li>Columns are separated by a comma</li>
<li><em>Extensions of the files (.CEL for example) should be removed</em></li>
</ul>
<p><strong>Example</strong></p>
<p>Let 3 .cel files in the studied dataset</p>
<p>patient1.cel<br>
patient2.cel<br>
patient3.cel</p>
<p>The csv file should look like this</p>
<p>files,response<br>
patient1,1.92145<br>
patient2,2.12481<br>
patient3,1.23545</p>
<h3 id="markers-selection-from-normalized-signal-matrix-data-a-namemarkers-selection-extracted--toc">Markers selection from normalized signal matrix data <a> </a><a href="#toc">[toc]</a></h3>
<p>This tool selects some relevant markers from normalized signal matrix data , according to a response using penalized regressions.</p>
<p>If you want to run this example, you need first to upload the <a href="https://github.com/sblanck/MPAgenomics4Galaxy/blob/master/reponse.csv">response.csv</a> file available on this github.</p>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/selection_extract.png" alt="Marker Selection"></p>
<p>The inputs are :</p>
<ul>
<li>A .sef (signal extraction file) generated by the <em>Extract</em> tool</li>
<li>A response .csv file</li>
<li>The number of folds for cross validation (must be lower than the number of samples in the .sef file)</li>
<li>The response type : Linear or Logistic</li>
</ul>
<p>The outputs are:</p>
<p>A tabular text file containing 5 columns which describe all the selected SNPs (1 line per SNPs):</p>
<ul>
<li>chr: Chromosome containing the selected SNP.</li>
<li>position: Position of the selected SNP.</li>
<li>index: Index of the selected SNP.</li>
<li>names: Name of the selected SNP.</li>
<li>coefficient: Regression coefficient of the selected SNP.</li>
</ul>
<p><strong>Data Response csv file</strong></p>
<p>Data response csv file format:</p>
<ul>
<li>The first column contains the names of the different files of the data-set.</li>
<li>The second column contains the response associated with each file.</li>
<li>Column names of these two columns are respectively files and response.</li>
<li>Columns are separated by a comma</li>
<li><em>Extensions of the files (.CEL for example) should be removed</em></li>
</ul>
<p><strong>Example</strong></p>
<p>Let 3 .cel files in the studied dataset</p>
<p>patient1.cel<br>
patient2.cel<br>
patient3.cel</p>
<p>The csv file should look like this</p>
<p>files,response<br>
patient1,1.92145<br>
patient2,2.12481<br>
patient3,1.23545</p>

