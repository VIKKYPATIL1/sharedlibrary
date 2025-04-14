#!/bin/bash

VERSION=$1
WORKDIR="/tmp/build_workspace/project"
REPORT_DIR="$WORKDIR/target/surefire-reports"
QA_EMAIL="qa@example.com"

exit_on_failure() {
  echo "[ERROR] $1"
  exit 1
}

echo "Starting Test Execution for version $VERSION..."

# --- Navigate to project directory ---
cd $WORKDIR || exit_on_failure "Project directory not found."

# --- Check if Maven is installed ---
command -v mvn >/dev/null 2>&1 || exit_on_failure "Maven is not installed."

# --- Clean and Run Tests ---
echo "Running unit tests..."
mvn test surefire-report:report || exit_on_failure "Test execution failed."

# --- Check for test result ---
if [ ! -d "$REPORT_DIR" ]; then
  exit_on_failure "Surefire report directory not found."
fi

echo "[INFO] Test reports generated."

# --- Mail Report to QA Team ---
echo "Mailing report to QA team..."
mail -s "Automated Test Report - Version $VERSION" $QA_EMAIL < $REPORT_DIR/index.html || echo "[WARNING] Unable to send mail."

echo "[SUCCESS] Test process completed."
