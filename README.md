---


---

<h1 id="mpagenomics4galaxy">MPAgenomics4Galaxy</h1>
<p>MPAgenomics, standing for multi-patients analysis (MPA) of genomic markers, is an R-package devoted to: (i) efficient segmentation, and (ii) genomic marker selection from multi-patient copy number and SNP data profiles. It provides wrappers from commonly used packages to facilitate their repeated (sometimes difficult) use, offering an easy-to-use pipeline for beginners in R. The segmentation of successive multiple profiles (finding losses and gains) is based on a new automatic choice of influential parameters since default ones were misleading in the original packages. Considering multiple profiles in the same time, MPAgenomics wraps efficient penalized regression methods to select relevant markers associated with a given response.</p>
<ul>
<li><a href="#how-to-install-mpa">How to install MPAgenomics</a>
<ul>
<li><a href="#from-the-galaxy-toolshed">From the galaxy toolshed</a></li>
<li><a href="#using-docker">Using docker</a></li>
</ul>
</li>
</ul>
<h2 id="how-to-install-smagexp--a-namehow-to-install-smagexp--toc">How to install SMAGEXP  <a> </a><a href="#toc">[toc]</a></h2>
<h3 id="from-the-galaxy-toolshed-a-namefrom-the-galaxy-toolshed--toc">From the galaxy toolshed <a> </a><a href="#toc">[toc]</a></h3>
<p><a href="https://testtoolshed.g2.bx.psu.edu/view/sblanck/mpagenomics_wrappers/af4f63f27c77">MPAgenomics wrappers are available on the galaxy test toolshed </a></p>
<p>You also have to install R dependencies</p>
<ul>
<li>
<p>From bioconductor :</p>
<ul>
<li>TODO</li>
</ul>
</li>
<li>
<p>From CRAN :</p>
<ul>
<li>TODO</li>
</ul>
</li>
</ul>
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

