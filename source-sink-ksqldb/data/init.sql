USE hapi-fhir;

CREATE TABLE IF NOT EXISTS Device (
  Device_id VARCHAR(100) DEFAULT 'abcd',
  Device_name VARCHAR(100) DEFAULT 'Unknown Name',
  Status_id INT,
  Measure_id INT,
  Ventilation_settings_id INT,
  Alarm_settings_id INT,
  Created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Status (
  Status_id INT,
  PatientType INT,
  VentilatorMode INT,
  O2_100 INT,
  ExpiPause INT,
  ExpiFlowSensor INT,
  VentilatorState INT,
  InspiPause INT,
  NIV INT,
  CO2Sensor INT,
  Created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Measure (
  Measure_id SERIAL PRIMARY KEY,
  -- Measure_id SERIAL PRIMARY KEY,
  Ppeak DOUBLE PRECISION,
  VTe DOUBLE PRECISION,
  RR DOUBLE PRECISION,
  MVe DOUBLE PRECISION,
  FiO2 DOUBLE PRECISION,
  Pmean DOUBLE PRECISION,
  Pplat DOUBLE PRECISION,
  PEEP DOUBLE PRECISION,
  VTi DOUBLE PRECISION,
  MVi DOUBLE PRECISION,
  TI_Ttot DOUBLE PRECISION,
  FinCO2 DOUBLE PRECISION,
  etCO2 DOUBLE PRECISION,
  Created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS VentilationSettings (
  Ventilation_settings_id INT,
  VT DOUBLE PRECISION,
  RR DOUBLE PRECISION,
  RR_mini DOUBLE PRECISION,
  RR_VSIMV DOUBLE PRECISION,
  PI DOUBLE PRECISION,
  PS DOUBLE PRECISION,
  PEEP DOUBLE PRECISION,
  I_E DOUBLE PRECISION,
  TI_Ttot DOUBLE PRECISION,
  Timax DOUBLE PRECISION,
  TrigI DOUBLE PRECISION,
  TrigE DOUBLE PRECISION,
  Pressure_slope DOUBLE PRECISION,
  PI_sigh DOUBLE PRECISION,
  Sigh_period DOUBLE PRECISION,
  Vt_target DOUBLE PRECISION,
  FiO2 DOUBLE PRECISION,
  Flow_shape DOUBLE PRECISION,
  Tplat DOUBLE PRECISION,
  Vtapnea DOUBLE PRECISION,
  F_apnea DOUBLE PRECISION,
  T_apnea DOUBLE PRECISION,
  Tins DOUBLE PRECISION,
  Pimax DOUBLE PRECISION,
  F_ent DOUBLE PRECISION,
  PS_PVACI DOUBLE PRECISION,
  FiO2_CPV DOUBLE PRECISION,
  RR_CPV DOUBLE PRECISION,
  PI_CPV DOUBLE PRECISION,
  Thigh_CPV DOUBLE PRECISION,
  Heigh DOUBLE PRECISION,
  Gender DOUBLE PRECISION,
  Coeff DOUBLE PRECISION,
  O2_low_pressure DOUBLE PRECISION,
  Peak_flow DOUBLE PRECISION,
  Created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS AlarmsSettings (
  Alarm_settings_id INT,
  Ppeak DOUBLE PRECISION,
  VTiMin DOUBLE PRECISION,
  VTiMax DOUBLE PRECISION,
  VTeMin DOUBLE PRECISION,
  VTeMax DOUBLE PRECISION,
  MViMin DOUBLE PRECISION,
  MViMax DOUBLE PRECISION,
  MVeMin DOUBLE PRECISION,
  MVeMax DOUBLE PRECISION,
  RR_min DOUBLE PRECISION,
  RR_max DOUBLE PRECISION,
  Fio2Min DOUBLE PRECISION,
  Fio2Max DOUBLE PRECISION,
  Etco2Min DOUBLE PRECISION,
  Etco2Max DOUBLE PRECISION,
  Fico2Max DOUBLE PRECISION,
  Pmin DOUBLE PRECISION,
  PplatMax DOUBLE PRECISION,
  FreqCTMin DOUBLE PRECISION,
  FreqCTMax DOUBLE PRECISION,
  Created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Device (Device_id, Device_name, Status_id, Measure_id, Ventilation_settings_id, Alarm_settings_id, Created_at)
VALUES ('mjaWpv', 'Unknown Name', 1, 1, 1, 1, CURRENT_TIMESTAMP), ('dgasdf', 'TEST', 2, 2, 2, 2, CURRENT_TIMESTAMP), ('ksdfad', 'TEST-1', 3, 3, 3, 3, CURRENT_TIMESTAMP);

INSERT INTO Measure (Measure_id, Ppeak, VTe, RR, MVe, FiO2, Pmean, Pplat, PEEP, VTi, MVi, TI_Ttot, FinCO2, etCO2, Created_at)
VALUES (1, 16.31, 9.58, 18.27, 16.53, 3.75, 19.08, 1.03, 15.93, 17.63, 1.06, 64.47, 51.73, 54.49, CURRENT_TIMESTAMP);

INSERT INTO Status (Status_id, PatientType, VentilatorMode, O2_100, ExpiPause, ExpiFlowSensor, VentilatorState, InspiPause, NIV, CO2Sensor, Created_at)
VALUES (1, 0, 5, 0, 1, 0, 0, 1, 0, 0, CURRENT_TIMESTAMP);

INSERT INTO VentilationSettings (Ventilation_settings_id, VT, RR, RR_mini, RR_VSIMV, PI, PS, PEEP, I_E, TI_Ttot, Timax, TrigI, TrigE, Pressure_slope, PI_sigh, Sigh_period, Vt_target, FiO2, Flow_shape, Tplat, Vtapnea, F_apnea, T_apnea, Tins, Pimax, F_ent, PS_PVACI, FiO2_CPV, RR_CPV, PI_CPV, Thigh_CPV, Heigh, Gender, Coeff, O2_low_pressure, Peak_flow, Created_at)
VALUES (1, 5.54, 7.24, 6.03, 6.7, 15.29, 4.53, 10.83, 1.43, 31.37, 19.33, 16.74, 19.43, 3.96, 15.98, 8.8, 9.56, 85.69, 0, 93.7, 1.35, 5.22, 5.54, 10.87, 45.13, 10.09, 10.57, 12.11, 3.07, 1.58, 10.09, 5.53, 18.78, 15.29, 12.67, 19.33, CURRENT_TIMESTAMP);

INSERT INTO AlarmsSettings (Alarm_settings_id, Ppeak, VTiMin, VTiMax, VTeMin, VTeMax, MViMin, MViMax, MVeMin, MVeMax, RR_min, RR_max, FiO2min, FiO2max, etCO2min, etCO2max, Fico2Max, PMin, PplatMax, FreqCTMin, FreqCTMax, Created_at)
VALUES (1, 20, 10, 25, 8, 30, 1, 2, 10, 35, 10, 25, 0.21, 1.0, 15, 20, 1, 5, 5, 20, 28, CURRENT_TIMESTAMP);

DROP TABLE Device;
DROP TABLE Measure;
DROP TABLE Status;
DROP TABLE VentilationSettings;
DROP TABLE AlarmsSettings;
