CREATE DATABASE readmissions

USE readmissions

SELECT * 
FROM 
	h_readmissions;

--Duplicate the table
SELECT * INTO
	h_readmissions2 
FROM 
	h_readmissions;

SELECT *
FROM 
	h_readmissions2

--Data Cleaning;

--fixing parenthesis error in the age column
UPDATE 
	h_readmissions2
SET 
	age= REPLACE(REPLACE(age, '[', '('), ')', ')');

UPDATE 
	h_readmissions2
SET 
	medical_specialty = REPLACE(medical_specialty, 'Missing', 'Unidentified');

--Exploratory Data analysis (EDA)
--Key metrics:

-- Distribution of patients in each age group;
SELECT age, COUNT(medical_specialty) as No_of_Patients
FROM 
	h_readmissions2
Group by 
	age
Order by 
	age;

--Average time in hospital for each age group:
SELECT 
	age, AVG(time_in_hospital) as avg_time_in_hospital
FROM 
	h_readmissions2
Group by 
	age
Order by 
	age;

	--Average time in hospital for readmitted (0) and non readmitted patients (1)
SELECT 
	readmitted,
	AVG(time_in_hospital) AS avg_lengh_of_stay_readmitted
FROM h_readmissions2
GROUP BY readmitted;

--Number of cases handled by each specialty 
SELECT 
	medical_specialty, COUNT(medical_specialty) as No_of_cases_handled
FROM 
	h_readmissions2
Group by
	medical_specialty
Order by 
	No_of_cases_handled
					asc;

--For each specialty, average number of lab procedures, normal procedures and medications given to patients
SELECT 
	medical_specialty, 
			AVG(n_lab_procedures) as avg_lab_procedures, 
			AVG(n_procedures) as avg_procedures,
			AVG(n_medications) as avg_medications
FROM 
	h_readmissions2
GROUP BY
	medical_specialty
ORDER BY 
	medical_specialty;

--The total and average number of previous in patient, outpatient and emergency admissions prior to the current admission by age
SELECT 
	age, SUM(n_inpatient) as no_inpatient_visits,
					SUM(n_outpatient) as no_outpatient_visits,
					SUM(n_emergency) as no_emergency_visits,
					AVG(n_inpatient) as avg_inpatient_visits,
					AVG(n_outpatient) as avg_outpatient_visits,
					AVG(n_emergency) as avg_emergency_visits
FROM 
	h_readmissions2
GROUP BY 
	age
Order by 
	age;

--Most frequent diagnoses in patients 
SELECT 
    diagnosis, 
    COUNT(*) AS frequency
FROM (
    SELECT diag_1 AS diagnosis FROM h_readmissions2
    UNION ALL
    SELECT diag_2 AS diagnosis FROM h_readmissions2
    UNION ALL
    SELECT diag_3 AS diagnosis FROM h_readmissions2
) combined
GROUP BY 
	diagnosis
ORDER BY 
	frequency 
ASC;

--Most Frequent diagnoses in primary, secondary and tertiary diagnoses
SELECT *
FROM(
   SELECT 
	'Primary' AS diag_type, 
    diag_1 AS diagnosis, 
    COUNT(*) AS frequency
FROM 
	h_readmissions2
GROUP BY 
	diag_1
UNION ALL
SELECT 
    'Secondary', 
    diag_2, 
    COUNT(*)
FROM 
	h_readmissions2
GROUP BY
	diag_2
UNION ALL
SELECT 
    'Tertiary', 
    diag_3, 
    COUNT(*)
FROM 
	h_readmissions2
GROUP BY diag_3) combined
ORDER BY 
	diag_type ASC;

--Readmission rate of each age group that were admitted
SELECT 
    age AS age_group,
    COUNT(CASE WHEN readmitted = 1 THEN 1 END) * 100.0 / COUNT(*) AS readmission_rate
FROM 
    h_readmissions2
GROUP BY 
    age
ORDER BY 
    readmission_rate DESC;

--Percentage readmitted
	SELECT 
    COUNT(CASE WHEN readmitted = 1 THEN 1 END) * 100.0 / COUNT(*) AS overall_readmission_rate
FROM 
    h_readmissions2

--Contribution of each age group to the readmission rate
	SELECT 
    age AS age_group,
    COUNT(CASE WHEN readmitted = 1 THEN 1 END) * 100.0 / 
    (SELECT COUNT(*) FROM h_readmissions2 WHERE readmitted = 1) AS readmission_percentage
FROM 
    h_readmissions2
GROUP BY 
    age
ORDER BY 
    readmission_percentage DESC;


--Readmission rates for patients with and without diabetes medications
SELECT 
    CASE 
    WHEN ISNULL(diabetes_med, 0) = 1 THEN 'With Diabetes Medications'
    WHEN ISNULL(diabetes_med, 0) = 0 THEN 'Without Diabetes Medications'
    ELSE 'Unknown'
    END AS 
		medication_status,
    COUNT(CASE WHEN readmitted = 1 THEN 1 END) * 100.0 / COUNT(*) AS readmission_rate
FROM 
    h_readmissions2
GROUP BY 
    ISNULL(diabetes_med, 0)
ORDER BY 
    readmission_rate DESC;


-- Readmission rate based on change in medication
SELECT 
    CASE 
    WHEN change = 1 THEN 'Medication Changed'
    WHEN change = 0 THEN 'No Medication Change'
    ELSE 'Unknown'
    END AS medication_change_status,
    COUNT(CASE WHEN readmitted = 1 THEN 1 END) * 100.0 / COUNT(*) AS readmission_rate
FROM 
    h_readmissions2
GROUP BY 
    change
ORDER BY 
    readmission_rate DESC;