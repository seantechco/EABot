# Use a specific Python version for consistency
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# 1. Install system dependencies AND REQUIRED CHROME LIBRARIES
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    # List of libraries required by Chrome/ChromeDriver
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libcups2 \
    libxss1 \
    libxrandr2 \
    libasound2 \
    libpango1.0-0 \
    libu2f-udev \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libdrm2 \
    libgbm1 \
    --no-install-recommends

# 2. Define a specific, known-good version of Chrome to use
ARG CHROME_VERSION="126.0.6478.126"

# 3. Download and install the specified Chrome and its matching ChromeDriver
RUN mkdir -p /opt/chrome \
    && wget -q https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chrome-linux64.zip -O chrome-linux64.zip \
    && wget -q https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip -O chromedriver-linux64.zip \
    && unzip chrome-linux64.zip \
    && unzip chromedriver-linux64.zip \
    && mv chrome-linux64/* /opt/chrome/ \
    && mv chromedriver-linux64/chromedriver /usr/bin/chromedriver \
    && rm chrome-linux64.zip chromedriver-linux64.zip \
    && rm -rf chrome-linux64 chromedriver-linux64 \
    && ln -s /opt/chrome/chrome /usr/bin/google-chrome

# 4. Copy and install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of your application code
COPY . .

# 6. Make the entrypoint script executable
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 7. Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# The default command to run when the container starts
CMD ["python", "main.py"]