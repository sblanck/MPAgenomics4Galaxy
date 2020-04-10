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
<li><a href="#filtering">Filtering</a></li>
<li><a href="#extract">Extract Copy number signal</a></li>
<li><a href="#seg-call-extracted">Segmentation and Calling of an extracted signal</a></li>
<li><a href="#markers-selection">Markers selection</a></li>
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
<p><a href="https://testtoolshed.g2.bx.psu.edu/view/sblanck/mpagenomics_wrappers/af4f63f27c77">MPAgenomics wrappers are available on the galaxy test toolshed </a></p>
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
<p>This step is done with the Data normalization tool which have the following inputs :</p>
<ul>
<li>A list of .CEL files</li>
<li>The 4 annotations files (.cdf, ufl, ugp, acs)</li>
<li>An optionnal csv file in a case of a normal-tumor study with tumor boost</li>
</ul>
<p>In cases where normal (control) samples match to tumor samples, normalization can be improved using TumorBoost. In this case, a normal-tumor csv file must be provided :</p>
<ul>
<li>The first column contains the names of the files corresponding to normal samples of the dataset.</li>
<li>The second column contains the names of the tumor samples files.</li>
<li>Column names of these two columns are respectively normal and tumor.</li>
<li>Columns are separated by a comma.</li>
<li>Extensions of the files (.CEL for example) should be removed</li>
</ul>
<p>Example of a normal-tumor csv file :</p>
<pre><code>normal,tumor
patient1_normal,patient1_tumor
patient2_normal,patient2_tumor
patient3_normal,patient3_tumor
</code></pre>
<p>The outputs are</p>
<ul>
<li>A .dsf file, summarizing the data</li>
<li>An optionnal log files</li>
<li>An optionnal zip file containing all the figures of the normalized data</li>
</ul>
<p><img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalization.png" alt="normalization"><br>
<img src="https://github.com/sblanck/MPAgenomics4Galaxy/raw/master/images/normalization2.png" alt="normalization"></p>
<h3 id="segmentation-and-calling-of-normalized-data--a-nameseg-call--toc">Segmentation and Calling of normalized data  <a> </a><a href="#toc">[toc]</a></h3>
<h3 id="filtering--a-namefiltering--toc">Filtering  <a> </a><a href="#toc">[toc]</a></h3>
<h3 id="extract-copy-number-signal--a-nameextract--toc">Extract Copy number signal  <a> </a><a href="#toc">[toc]</a></h3>
<h3 id="segmentation-and-calling-of-an-extracted-signal--a-nameseg-call-extracted--toc">Segmentation and Calling of an extracted signal  <a> </a><a href="#toc">[toc]</a></h3>
<h3 id="markers-selection--a-namemarkers-selection--toc">Markers selection  <a> </a><a href="#toc">[toc]</a></h3>

