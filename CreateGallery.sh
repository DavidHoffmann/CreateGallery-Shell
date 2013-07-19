#!/bin/bash

# This file is part of CreateGallery
# Copyright (C) 2013 David Hoffmann
#
# CreateGallery is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, version 2.
#
# CreateGallery is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CreateGallery; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


# Example: ./CeateGallery.sh "/tmp/*.jpg" "My gallery"

# Create temp directory
DSTDIR=`mktemp -d`

# copy lightbox2 files to gallery
cp -Rf `dirname ${0}`/lightbox2 ${DSTDIR}/lightbox2

cat <<EOF > ${DSTDIR}/index.html
<html>
<head>
<title>${2}</title>
<meta name="generator" content="https://github.com/DavidHoffmann/CreateGallery-Shell" />
<meta name="robots" content="noindex,nofollow" />
<link href="lightbox2/css/lightbox.css" rel="stylesheet" />
<script src="lightbox2/js/jquery-1.10.2.min.js"></script>
<script src="lightbox2/js/lightbox-2.6.min.js"></script>
</head>
<body>
<h1>${2}</h1>
EOF

echo "copy images to tmp"
mkdir -p ${DSTDIR}/tmp
cp ${1} ${DSTDIR}/tmp

mkdir -p ${DSTDIR}/thumbs
mkdir -p ${DSTDIR}/images

echo "convert images"
for f in ${DSTDIR}/tmp/*
do
BF=`basename ${f}`
DSTTHUMBFILE=${DSTDIR}/thumbs/${BF}
DSTIMAGEFILE=${DSTDIR}/images/${BF}

# autorotate
jhead -autorot ${f}

height=`identify -format %h "${f}"`
width=`identify -format %w "${f}"`
ratio=`expr ${width} / ${height}`

if [ ${ratio} -eq "0" ]
then
    convert -thumbnail 89 ${f} ${DSTTHUMBFILE}
    convert -thumbnail 360 ${f} ${DSTIMAGEFILE}

else
    convert -thumbnail 200 ${f} ${DSTTHUMBFILE}
    convert -thumbnail 800 ${f} ${DSTIMAGEFILE}
fi

# add watermark
if [ -e "`dirname ${0}`/photograph.png" ]
then
    composite -gravity SouthWest "`dirname ${0}`/photograph.png" ${DSTIMAGEFILE} ${DSTIMAGEFILE} 
fi

# add image to html file
echo "<a href=\"images/${BF}\" rel=\"lightbox\" data-lightbox=\"gal\"><img class=\"gallery\" src=\"thumbs/${BF}\" alt=\"thumbnail image\" /></a>" >> ${DSTDIR}/index.html

done

cat <<EOF >> ${DSTDIR}/index.html
</body>
</html>
EOF

# delete temp files
rm -Rf ${DSTDIR}/tmp
rm -Rf ${DSTDIR}/lightbox2/releases

echo ${DSTDIR}


#ls *.JPG | xargs -n1 -I% echo '<li><a href="%" rel="lightbox"><img class="gallery" src="thumbs/%" alt="thumbnail image"/></a\></li>' >> la.html; ls *.JPG | xargs -n1 -I% convert -thumbnail 200 % thumbs/%
