FROM caddy:latest

# Set the working directory
WORKDIR /usr/share/caddy

# Copy Caddyfile and index.html into the container
COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html index.html

# Expose the port that the app will run on (usually 8080 by default)
EXPOSE 8080
