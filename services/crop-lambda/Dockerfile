FROM public.ecr.aws/lambda/nodejs:22

WORKDIR /var/task

COPY package.json ./
RUN npm install --omit=dev

COPY index.js ./

CMD ["index.handler"]
