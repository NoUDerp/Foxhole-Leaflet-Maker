ARG ARCH
FROM ${ARCH}alpine:3.13.4
ARG ARCH ARG CLIB= ARG TILER_EXTENSION=
RUN apk add --no-cache krb5-dev libwebp-tools git imagemagick icu-libs ffmpeg bash zip bc wget
RUN wget "https://github.com/NoUDerp/Tiler/raw/master/binaries/Tiler-Linux-${CLIB}${ARCH}${TILER_EXTENSION}" -O /Tiler
RUN chmod +x /Tiler
COPY stitch.sh /stitch.sh
RUN echo "#!/bin/bash" >> /run.sh
RUN echo "mkdir -p /warapi 1>&2" >> /run.sh

RUN echo -e "repository=\"https://github.com/clapfoot/warapi.git\"" >> /run.sh
RUN echo -e "subdirectory=\"0\"" >> /run.sh
RUN echo -e "branch=\"master\"" >> /run.sh
RUN echo -e "while [ \$# -gt 0 ]; do" >> /run.sh 
RUN echo -e "	case \"\$1\" in" >> /run.sh 
RUN echo -e "		-r | --repository ) shift; repository=\"\$1\";;" >> /run.sh
RUN echo -e "		-s | --subdirectory ) subdirectory=\"1\";;" >> /run.sh
RUN echo -e "		-b | --branch ) shift; branch=\"\$1\";;" >> /run.sh
RUN echo -e "	esac" >> /run.sh
RUN echo -e "	shift" >> /run.sh
RUN echo -e "done" >> /run.sh		 

RUN echo "cd /warapi" >> /run.sh
RUN echo -e "git config --global init.defaultBranch \"\$branch\"" >> /run.sh
RUN echo "git init 1>&2" >> /run.sh
RUN echo -e "git remote add -f origin \"\$repository\" 1>&2" >> /run.sh
RUN echo "git config core.sparseCheckout true 1>&2" >> /run.sh
RUN echo -e "echo \"Images/Maps\" >> .git/info/sparse-checkout" >> /run.sh
RUN echo -e "git pull origin \"\$branch\" 1>&2" >> /run.sh
RUN echo "cd /warapi/Images/Maps" >> /run.sh
RUN echo -e "IFS=\$'\\n'" >> /run.sh
RUN echo -e "for f in \$(ls *.TGA); do ffmpeg -i \"\$f\" \"\$(echo \"\$f\" | sed 's/\.TGA/.png/')\" -y 2>/dev/null 1>/dev/null && rm \"\$f\" 2>/dev/null 1>/dev/null; done" >> /run.sh
RUN echo "/stitch.sh 1>&2" >> /run.sh
RUN mkdir -p /final && echo "mv map.png /final/FullMap.png 1>&2" >> /run.sh
RUN echo "/Tiler /final/FullMap.png 1>&2" >> /run.sh
RUN echo "mv /final/FullMap.png-tiles /final/Tiles 1>&2" >> /run.sh
RUN echo -e "if [ \"\$subdirectory\" -eq \"1\" ]; then" >> /run.sh
RUN echo -e "	cd /final/Tiles; for f in \$(ls *.png); do d=\$(echo \"\$f\" | sed 's/\\([0-9]\+\\).*/\\\1/'); mkdir -p \"/final/Tiles/\$d\"; mv \"\$f\" \"/final/Tiles/\$d/\"; done" >> /run.sh
RUN echo "fi" >> /run.sh
RUN echo "for f in \$(find /final -name \"*.png\"); do cwebp \"\$f\" -lossless -o \"\$(echo \"\$f\" | sed 's/\.png/.webp/')\" 1>/dev/null 2>/dev/null; done" >> /run.sh
RUN echo "cd /final" >> /run.sh
RUN echo "zip -r -9 - ." >> /run.sh
RUN chmod +x /run.sh && chmod +x /stitch.sh && chmod +x /Tiler
ENTRYPOINT ["/run.sh"]
