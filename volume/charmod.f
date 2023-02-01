      MODULE CHARMOD

C     Module to store utility type definitions

C     Created TEH 02/24/09
C     Revised TDH 02/27/09 .

C     Class for receiving strings in calls from C++
      TYPE CHAR256
      SEQUENCE
        INTEGER        LENGTH
        CHARACTER(256) STR
      END TYPE CHAR256


      END MODULE CHARMOD
