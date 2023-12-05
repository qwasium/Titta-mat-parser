# export-Titta-mat

Tested on:

- MATLAB R2023a Update 5
- GNU Octave 6.4.0
- Ubuntu 22.04

---

## Description

This is a code for exporting output structure of [dcnieho/Titta](https://github.com/dcnieho/Titta.git) to delimited files.

This code will create a table(MATLAB) or struct(GNU Octave) where each field only contains a single row of data with the same length for easy data export.

I encourage the user to dig into the code and use inheritance/polyphormism to add custom actions to the output.

I know this code is very much incomplete, so please feel free to open a pull request.

## Quick Start

```matlab
% load titta output (shown as data.mat here)
tittaMat = load('data.mat');

% convert to table
data = titta2delim(tittaMat);
data.main();

% write to csv
writetable(data.sessionInfo, 'sesionInfo.csv');
writetable(data.timeSeries, 'timeSeries.csv');
writetable(data.messages, 'messages.csv');
writetable(data.TobiiLog, 'TobiiLog.csv');
writetable(data.notifications, 'notifications.csv');
```

Check out [/readmeDemo](./readDemo) for more details.

- MATLAB: readmeDemo/matlabDemo.mlx
- GNU Octave: readmeDemo/octaveDemo.ipynb

## execution order

The code is executed in the following order:

**`titta2delim()`**: constructor, adds key map if provided

- `addKeyMap()`

**`main()`**: main function; calls the following functions in order

- `createSessionInfo()`
  - functions to add each row of `sessionInfo`
  - `userDefinedSessionInfo()`: empty; modify this function for custom actions to `sessionInfo`
- `createTimeSeries()`
  - functions to add each row of `timeSeries`
  - `userDefinedTimeSeries()`: empty; modify this function for custom actions to `timeSeries`
- `createLog()`
  - functions to create `TobiiLog`, `notifications`, and `messages`
  - `userDefinedLog()`: empty; modify this function for custom actions to `TobiiLog`
- `createCalibration()`: empty; not implemented
- `userDefinedMain()`: modify this function for custom actions to `main()`

## NOTE

- This code is meant to be modified using inheritance/polyphormism. The user should modify the functions in `userDefinedSessionInfo()`, `userDefinedTimeSeries()`, `userDefinedLog()`, and `userDefinedMain()` to add custom actions to the output. See [/readmeDemo](./readDemo) for examples.

- Most of the methods are designed to be called independently by the user, mainly for custom or one-time operations for adding a column. Documentation for each method can be found in the docstrings of each method in the source code.

- Some methods are not implemented yet. They are described in `createSessionInfo()`, `createTimeSeries()`, and `createLog()`.

- I have not been able to read the entire source code of Titta, and lack deep understanding of how the Tobii SDK C output corresponds to Titta output. Please feel free to open a pull request if you find anything that should be fixed.
