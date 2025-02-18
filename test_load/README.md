# Installing JMeter

## Prerequisites

Before you begin, make sure you have the following:

- Homebrew installed on your system. If you don't have it, you can install it by following the instructions at [https://brew.sh/](https://brew.sh/).

## Installation

To install JMeter using Homebrew, follow these steps:

1. Open your terminal.
2. Run the following command to update Homebrew:
   ```
   brew update
   ```
3. Run the following command to install JMeter:
   ```
   brew install jmeter
   ```

After install you can open the JMX file in this repo to test the installation. The tests can be run from the GUI but its recommended to use the CLI using the following guide.

# Running the Tests

## Command Structure

flags:

- -n : Non Gui Mode
- -l : Log file location (raw results of each request)
- -f : Force delete previous run results
- -t : Name of JMX file to run
- -e : Output report page
- -o : Folder for report page generation
- -J*var*: Variable overrides

variables:

- **Jtest_name**: Either 'search' or 'filters_combined' (default 'filters_combined')
- **Jloops**: Number of iterations to perform (default 1)
- **Jnum_users**: Number of users (default 100)
- **Jramp_time**: Time in seconds to ramp up to num_users (default 60)
- **Jbase_url**: Base Url (default localhost)
- **Jport_num**: Port number (default 80)
- **Jprotocol**: Protocol (default http)

## Tests

Filters 5 stage test includes:

1. Login
2. Filter x 1
3. Filter x 2
4. Add search
5. Add country
6. Remove Filter x 1

_**Assuming starting from the root folder**_

### Scenario 1 (10 users x 60 seconds)

```bash
export test=filters_combined users=10 time=60 loops=1 outputReportFolder=${test}_${users}_${time} outputFolder='./data/reports/load'

jmeter \
   -nfe \
   -l $outputFolder/log.csv \
   -j $outputFolder/jmeter.log \
   -t ./test_load/repository_tests.jmx  \
   -o $outputFolder/$outputReportFolder \
   -Jtest_name=$test \
   -Jnum_users=$users \
   -Jramp_time=$time \
   -Jloops=$loops \
   -Jprotocol=http \
   -Jport_num="80" \
   -Jbase_url="ird.antleaf.com"
```


### Scenario 2 (20 users x 60 seconds x 10 loops)

```bash
export test=filters_combined users=20 time=60 loops=10 outputReportFolder=${test}_${users}_${time} outputFolder='./data/reports/load'

jmeter \
   -nfe \
   -l $outputFolder/log.csv \
   -j $outputFolder/jmeter.log \
   -t ./test_load/repository_tests.jmx  \
   -o $outputFolder/$outputReportFolder \
   -Jtest_name=$test \
   -Jnum_users=$users \
   -Jramp_time=$time \
   -Jloops=$loops \
   -Jprotocol=http \
   -Jport_num="80" \
   -Jbase_url="ird.antleaf.com"
```

### Scenario 3 (100 users x 60 seconds x 10 loops)

```bash
export test=filters_combined users=100 time=60 loops=10 outputReportFolder=${test}_${users}_${time} outputFolder='./data/reports/load'

jmeter \
   -nfe \
   -l $outputFolder/log.csv \
   -j $outputFolder/jmeter.log \
   -t ./test_load/repository_tests.jmx  \
   -o $outputFolder/$outputReportFolder \
   -Jtest_name=$test \
   -Jnum_users=$users \
   -Jramp_time=$time \
   -Jloops=$loops \
   -Jprotocol=http \
   -Jport_num="80" \
   -Jbase_url="ird.antleaf.com"
```

### Scenario 4 (1000 users x 120 seconds)

```bash
export test=filters_combined users=1000 time=120 outputReportFolder=${test}_${users}_${time} outputFolder='./data/reports/load'

jmeter \
   -nfe \
   -l $outputFolder/log.csv \
   -j $outputFolder/jmeter.log \
   -t ./test_load/repository_tests.jmx  \
   -o $outputFolder/$outputReportFolder \
   -Jtest_name=$test \
   -Jnum_users=$users \
   -Jramp_time=$time \
   -Jloops=$loops \
   -Jprotocol=http \
   -Jport_num="80" \
   -Jbase_url="ird.antleaf.com"
```

Simple search stage test includes:

1. Login
2. Search using term 'education'

### Scenario 1 (10 users x 60 seconds)

```bash
export test=search users=10 time=60
export outputReportFolder=${test}_${users}_${time}
export outputFolder='./data/reports/load'
jmeter -n -l $outputFolder/log.csv -j $outputFolder/jmeter.log -f  -t ./test_load/repository_tests.jmx  -e -o $outputFolder/$outputReportFolder -Jtest_name=$test -Jnum_users=$users -Jramp_time=$time -Jport_num=**ENTER_PORT** -Jbase_url=**BASE_URL** -Jloops=$loops -Jprotocol=https
```

### Scenario 2 (20 users x 60 seconds x 10 loops)

```bash
export test=search users=20 time=60 loops=10
export outputReportFolder=${test}_${users}_${time}
export outputFolder='./data/reports/load'
jmeter -n -l $outputFolder/log.csv -j $outputFolder/jmeter.log -f  -t ./test_load/repository_tests.jmx  -e -o $outputFolder/$outputReportFolder -Jtest_name=$test -Jnum_users=$users -Jramp_time=$time -Jport_num=**ENTER_PORT** -Jbase_url=**BASE_URL** -Jloops=$loops -Jprotocol=https
```

### Scenario 3 (100 users x 60 seconds x 10 loops)

```bash
export test=search users=100 time=60 loops=10
export outputReportFolder=${test}_${users}_${time}
export outputFolder='./data/reports/load'
jmeter -n -l $outputFolder/log.csv -j $outputFolder/jmeter.log -f  -t ./test_load/repository_tests.jmx  -e -o $outputFolder/$outputReportFolder -Jtest_name=$test -Jnum_users=$users -Jramp_time=$time -Jport_num=**ENTER_PORT** -Jbase_url=**BASE_URL** -Jloops=$loops -Jprotocol=https
```

### Scenario 4 (1000 users x 120 seconds)

```bash
export test=search users=1000 time=120
export outputReportFolder=${test}_${users}_${time}
export outputFolder='./data/reports/load'
jmeter -n -l $outputFolder/log.csv -j $outputFolder/jmeter.log -f  -t ./test_load/repository_tests.jmx  -e -o $outputFolder/$outputReportFolder -Jtest_name=$test -Jnum_users=$users -Jramp_time=$time -Jport_num=**ENTER_PORT** -Jbase_url=**BASE_URL** -Jloops=$loops -Jprotocol=https
```

## Viewing Results

Each test run generates the following

1. **log.csv**: The raw results of each request
2. **./report** folder: A dashboard of results that can be viewed from your local browser:

The dashboard has an overall results section:

![Homepage](./example_images/overview.png)

And charts for response time:

![Charts](./example_images/graphs.png)
