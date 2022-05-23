/*Scenario 1*/
select mailing_state, count(pat_key) from PATIENT_ALL
group by mailing_state

/*Scenario 2*/
select mailing_zip, mailing_city, avg(current_age) as age_average from PATIENT_ALL
where lower(mailing_city) = 'philadelphia'
group by mailing_zip, mailing_city

/*Scenario 3*/
select patient_all.preferred_language, patient_all.patient_name, patient_all.mrn, encounter_specialty_care.visit_key,
encounter_specialty_care.encounter_date, encounter_specialty_care.provider_name,encounter_specialty_care.specialty_name
from encounter_specialty_care
LEFT JOIN PATIENT_ALL on PATIENT_ALL.PAT_KEY = ENCOUNTER_SPECIALTY_CARE.pat_key
where encounter_date >= '2022-04-01' and encounter_date <= '2022-04-30'
and lower(specialty_name) like 'allergy'

/*Scenario 4*/
select max(inpatient_admit_date) as recent_admit_date, min(inpatient_admit_date) as first_admit_date
from ENCOUNTER_INPATIENT
where lower(admission_department) like 'mbu'

/*Scenario 5*/
select encounter_ed.primary_reason_for_visit_name,
encounter_ed.medically_complex_ind,
CARE_NETWORK_PRIMARY_CARE_ACTIVE_PATIENTS.pc_active_patient_ind,
avg(encounter_ed.ed_los_hrs) as average_stay,
count(encounter_ed.visit_key) as number_visits
from CHOP_ANALYTICS..ENCOUNTER_ED
left join CHOP_ANALYTICS..CARE_NETWORK_PRIMARY_CARE_ACTIVE_PATIENTS on CARE_NETWORK_PRIMARY_CARE_ACTIVE_PATIENTS.PAT_KEY = ENCOUNTER_ED.PAT_KEY
where encounter_date = '2021-07-04' and MEDICALLY_COMPLEX_IND = '0'
and month_year = '2021-07-01' and pc_active_patient_ind = '1'
group by primary_reason_for_visit_name, medically_complex_ind, pc_active_patient_ind
order by number_visits desc


/*Scenario 6*/
/*followed through solution-struggled with*/
select 
	patient_all.patient_name,
	patient_all.mrn,
	patient_all.current_age,
	patient_all.gestational_age_complete_weeks,
	encounter_primary_care.encounter_date,
	encounter_primary_care.department_name,
    case when lower(patient_all.mailing_city) = 'phila%' then 1 else 0 end as philly_ind
from 
    chop_analytics.blocks_clinical.encounter_primary_care
    inner join chop_analytics.blocks_clinical.patient_all on patient_all.pat_key = encounter_primary_care.pat_key 
where 
    encounter_primary_care.office_visit_ind = 1 
	and patient_all.gestational_age_complete_weeks < 36 and patient_all.gestational_age_complete_weeks >= 30
	and encounter_primary_care.encounter_date >= '2020-07-01' and encounter_primary_care.encounter_date <= '2021-06-30' 
;

/*Scenario 6-pt2*/
/*followed through solution-struggled*/
select 
	patient_all.patient_name,
	patient_all.mrn,
	patient_all.current_age,
	max(encounter_date) as last_seen_date --last seen, so max encounter_date
from 
    chop_analytics.blocks_clinical.encounter_primary_care
    inner join chop_analytics.blocks_clinical.patient_all on patient_all.pat_key = encounter_primary_care.pat_key 
where 
    encounter_primary_care.office_visit_ind = 1 
	and patient_all.gestational_age_complete_weeks < 36 and patient_all.gestational_age_complete_weeks >= 30
	and encounter_primary_care.encounter_date >= '2020-07-01' and encounter_primary_care.encounter_date <= '2021-06-30' 
group by 
	patient_all.patient_name,
	patient_all.mrn,
	patient_all.current_age
;

/*Scenario 7*/
/*followed through solution-struggled*/
select
    encounter_primary_care.pat_key,
    encounter_primary_care.patient_name,
    encounter_primary_care.mrn,
    encounter_primary_care.dob,
    count(encounter_primary_care.visit_key) as visit_count,
    max(case when encounter_primary_care.provider_name = 'Christie, Melissa' then 1 else 0 end) as appt_with_dr_christie_ind 
from 
    chop_analytics.blocks_clinical.encounter_primary_care
where
    encounter_primary_care.encounter_date >= '2022-01-01' and encounter_primary_care.encounter_date <= '2022-03-31' -- FY22 Quarter 3
    and encounter_primary_care.department_id = 76306012 --'DREXEL HILL CARE NTWK'
group by
    encounter_primary_care.pat_key,
    encounter_primary_care.patient_name,
    encounter_primary_care.mrn,
    encounter_primary_care.dob
;