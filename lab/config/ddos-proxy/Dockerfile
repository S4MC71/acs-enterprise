FROM nginx:alpine

COPY nginx-ddos.conf /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
