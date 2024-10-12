# `time` module

## Format

The following table shows the possible modifiers that can be used when parsing
and formatting dates.

|                  | Modifier | Output                                 |
|-----------------:|:---------|:---------------------------------------|
|        **Month** | M        | 1 2 ... 11 12                          |
|                  | _M       | \<space>1 .. 12                        |
|                  | Mo       | 1st 2nd ... 11th 12th                  |
|                  | MM       | 01 02 ... 11 12                        |
|                  | MMM      | Jan Feb ... Nov Dec                    |
|                  | MMMM     | January February ... November December |
|      **Quarter** | Q        | 1 2 3 4                                |
|                  | QQ       | 01 02 03 04                            |
|                  | Qo       | 1st 2nd 3rd 4th                        |
| **Day of Month** | D        | 1 2 ... 30 31                          |
|                  | _D       | \<space>1 .. 30 31                     |
|                  | Do       | 1st 2nd ... 30th 31st                  |
|                  | DD       | 01 02 ... 30 31                        |
|  **Day of Year** | DDD      | 1 2 ... 364 365                        |
|                  | DDDo     | 1st 2nd ... 364th 365th                |
|                  | DDDD     | 001 002 ... 364 365                    |
|  **Day of Week** | W        | Sun Mon ... Fri Sat                    |
|                  | WW       | Sunday Monday ... Friday Saturday      |
|         **Year** | YY       | 70 71 ... 29 30                        |
|                  | YYYY     | 1970 1971 ... 2029 2030                |
|        **AM/PM** | PM       | AM PM                                  |
|         **Hour** | h        | 0 1 ... 22 23                          |
|                  | hh       | 00 01 ... 22 23                        |
|       **Minute** | m        | 0 1 ... 58 59                          |
|                  | mm       | 00 01 ... 58 59                        |
|       **Second** | s        | 0 1 ... 58 59                          |
|                  | ss       | 00 01 ... 58 59                        |
|       **Offset** | Z        | -7 -6 ... +5 +6                        |
|                  | ZZ       | -0700 -0600 ... +0500 +0600            |
|                  | ZZZ      | -07:00 -06:00 ... +05:00 +06:00        |
|                  | ZZZZ     | MST                                    |

