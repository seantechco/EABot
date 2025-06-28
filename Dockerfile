FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# 1. Install system dependencies, including the virtual screen (Xvfb) and Chrome
RUN apt-get update && apt-get install -y \
    xvfb \
    wget \
    unzip \
    --no-install-recommends

# 2. Install Google Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

# 3. Install the matching ChromeDriver
# Find the latest stable chromedriver version from the new JSON endpoints
RUN CHROME_VERSION=$(google-chrome --version | cut -f 3 -d ' ' | cut -d '.' -f 1-3) \
    && DRIVER_VERSION=$(wget -qO- "https://googlechromelabs.github.io/chrome-for-testing/latest-stable-versions-per-milestone.json" | grep -A1 "\"$CHROME_VERSION\"" | grep "version" | cut -d '"' -f 4) \
    && wget -q "https://storage.googleapis.com/chrome-for-testing-public/$DRIVER_VERSION/linux64/chromedriver-linux64.zip" \
    && unzip chromedriver-linux64.zip \
    && mv chromedriver-linux64/chromedriver /usr/bin/chromedriver \
    && rm chromedriver-linux64.zip \
    && rm -rf chromedriver-linux64

# 4. Copy and install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of your application code
COPY . .

# 6. Make the entrypoint script executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 7. Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# The default command to run when the container starts
CMD ["python", "main.py"]