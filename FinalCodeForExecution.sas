/* Sampling */

proc surveyselect data=AZSQL.CUSTOMERS out=work.sample_customers method=srs 
		samprate=0.5 seed=555;
run;

proc surveyselect data=AZSQL.facilities out=work.sample_facilities method=srs 
		samprate=0.5 seed=555;
run;

proc surveyselect data=AZSQL.orders out=work.sample_orders method=srs 
		samprate=0.5 seed=555;
run;


proc surveyselect data=AZSQL.salesreps out=work.sample_salesreps method=srs 
		samprate=0.5 seed=555;
run;


proc surveyselect data=AZSQL.products out=work.sample_products method=srs 
		samprate=0.5 seed=555;
run;

PROC SQL;
	CREATE TABLE WORK.JOINED_DATA AS
		SELECT
			t1.TransactionDate,
			t1.Unit,
			t1.UnitActual,
			t1.UnitCapacity,
			t1.UnitDiscardRate,
			t1.UnitDiscards,
			t1.UnitLifespan,
			t1.UnitLifespanLimit,
			t1.UnitReliability,
			t1.UnitStatus,
			t1.UnitStatusCode,
			t1.UnitTarget,
			t1.UnitYieldRate,
			t1.Product,
			t1.SalesRepID,
			t1.Customer,
			t1.Facility,
			t2.CustomerDistance,
			t2.CustomerLat,
			t2.CustomerLon,
			t2.CustomerSatisfaction,
			t2.ReturningCustomer,
			t2.ReturningCustomerNum,
			t3.ProductBrand,
			t3.ProductCostOfSale,
			t3.ProductLine,
			t3.ProductMake,
			t3.ProductMaterialCost,
			t3.ProductPriceActual,
			t3.ProductPriceTarget,
			t3.ProductQuality,
			t3.ProductStyle,
			t4.SalesRep,
			t4.SalesRepCustomerBase,
			t4.SalesRepCustomers,
			t4.SalesRepRating,
			t5.FacilityCity,
			t5.FacilityContinent,
			t5.FacilityCountry,
			t5.FacilityEfficiency,
			t5.FacilityEmployees,
			t5.FacilityOpeningDate,
			t5.FacilityRegion
		FROM
			sample_orders t1
				INNER JOIN sample_CUSTOMERS t2 ON (t1.Customer = t2.Customer)
				INNER JOIN sample_PRODUCTS t3 ON (t1.Product = t3.Product)
				INNER JOIN sample_SALESREPS t4 ON (t1.SalesRepID = t4.SalesRepID)
				INNER JOIN sample_FACILITIES t5 ON (t1.Facility = t5.Facility)
	;
QUIT;
RUN;

PROC SQL;
	CREATE TABLE WORK.JOINED_PREPPED_DATA AS
		SELECT
			t1.TransactionDate,
			t1.Unit,
			t1.UnitActual,
			t1.UnitCapacity,
			t1.UnitDiscardRate,
			t1.UnitDiscards,
			t1.UnitLifespan,
			t1.UnitLifespanLimit,
			t1.UnitReliability,
			t1.UnitStatus,
			t1.UnitStatusCode,
			t1.UnitTarget,
			t1.UnitYieldRate,
			t1.Product,
			t1.SalesRepID,
			t1.Customer,
			t1.Facility,
			t1.CustomerDistance,
			t1.CustomerLat,
			t1.CustomerLon,
			t1.ReturningCustomer,
			t1.ReturningCustomerNum,
			t1.ProductBrand,
			t1.ProductCostOfSale,
			t1.ProductLine,
			t1.ProductMake,
			t1.ProductMaterialCost,
			t1.ProductPriceActual,
			t1.ProductPriceTarget,
			t1.ProductQuality,
			t1.ProductStyle,
			t1.SalesRep,
			t1.SalesRepCustomerBase,
			t1.SalesRepCustomers,
			t1.SalesRepRating,
			t1.FacilityCity,
			t1.FacilityContinent,
			t1.FacilityCountry,
			t1.FacilityEfficiency,
			(YEAR( TODAY() ) - YEAR(t1.FacilityOpeningDate )) AS facility_age,
			t1.FacilityEmployees,
			t1.FacilityOpeningDate,
			(CASE   WHEN (t1.CustomerSatisfaction ge 0 and t1.CustomerSatisfaction lt 0.33) THEN "A"   WHEN (t1.CustomerSatisfaction ge 0.33 and t1.CustomerSatisfaction lt 0.66) THEN "B"   WHEN (t1.CustomerSatisfaction ge 0.66 and t1.CustomerSatisfaction lt 1) THEN "C" END) AS grouped_cust_satisfaction,
			t1.FacilityRegion
		FROM
			WORK.JOINED_DATA t1
	;
QUIT;
RUN;

ODS GRAPHICS ON;
 
PROC HPSPLIT DATA = WORK.JOINED_PREPPED_DATA ;
    CLASS grouped_cust_satisfaction _CHARACTER_;
    MODEL grouped_cust_satisfaction = _NUMERIC_ _CHARACTER_;
    PRUNE costcomplexity;
    PARTITION FRACTION(VALIDATE=0.3 SEED=42);
    OUTPUT OUT = SCORED ;
run;

