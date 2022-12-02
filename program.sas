proc surveyselect data=AZSQL.CUSTOMERS out=work.sample_customers method=srs 
		samprate=0.5 seed=555;
run;