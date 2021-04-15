USE H_Accounting;

DROP PROCEDURE IF EXISTS `smedina2019_sp`;
-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

	CREATE PROCEDURE `smedina2019_sp`(varCalendarYear YEAR)
	BEGIN
	
  
	-- We can define variables inside of our procedure
		DECLARE varTotalRevenues, varTotalReturns, varTotalOtherInc, varTotalCOGS, varTotalADEXP, varTotalSelling, varTotalOtherExp, varTotalIncTax,
        varTotalOtherTax DOUBLE DEFAULT 0;
        
  
	--  We calculate the value of the sales for the given year and we store it into the variable we just declared
		SELECT SUM(jeli.credit) INTO varTotalRevenues 

		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "REV" 
				AND YEAR(je.entry_date) = varCalendarYear;
                
	-- Looking at Returns
		SELECT IFNULL(SUM(jeli.debit),0) INTO  varTotalReturns
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "RET"
				AND YEAR(je.entry_date) = varCalendarYear;
                
                
	-- Looking at COGS
		SELECT SUM(jeli.debit) INTO  varTotalCOGS
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "COGS"
				AND YEAR(je.entry_date) = varCalendarYear;
                
	-- Looking at Admin expenses
		SELECT IFNULL(SUM(jeli.debit),0) INTO  varTotalADEXP
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "GEXP"
				AND YEAR(je.entry_date) = varCalendarYear;
                
	-- Looking at selling expenses
		SELECT SUM(jeli.debit) INTO  varTotalSelling
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "SEXP"
				AND YEAR(je.entry_date) = varCalendarYear;
	-- Looking at other expenses
		SELECT SUM(jeli.debit) INTO  varTotalOtherExp
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "OEXP"
				AND YEAR(je.entry_date) = varCalendarYear;
	
    -- Other Income
		SELECT SUM(jeli.credit) INTO varTotalOtherInc
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "OI" 
				AND YEAR(je.entry_date) = varCalendarYear;
                
                
 --  Income Tax
		SELECT IFNULL(SUM(jeli.debit),0) INTO varTotalIncTax
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "INCTAX" 
				AND YEAR(je.entry_date) = varCalendarYear;
                
--  Other Tax
		SELECT IFNULL(SUM(jeli.debit),0) INTO varTotalOtherTax
		
			FROM journal_entry_line_item AS jeli
		
				INNER JOIN account 						AS ac ON ac.account_id = jeli.account_id
				INNER JOIN journal_entry 			AS je ON je.journal_entry_id = jeli.journal_entry_id
				INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
      
			WHERE ss.statement_section_code = "OTHTAX" 
				AND YEAR(je.entry_date) = varCalendarYear;
		 
	-- Let's drop the `tmp` table where we will input the revenue
	-- The IF EXISTS is important. Because if the table does not exist the DROP alone would fail
	-- A store procedure will stop running whenever it faces an error. 
		DROP TABLE IF EXISTS tmp_smedina2019_table;
  
	-- Now we are certain that the table does not exist, we create with the columns that we need
		CREATE TABLE tmp_smedina2019_table
		( profit_loss_line_number INT, 
			label VARCHAR(50), 
			amount VARCHAR(50)
		);
  
  -- Now we insert the a header for the report
  INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
		VALUES (1, 'PROFIT AND LOSS STATEMENT', "In '000s of USD");
  
  -- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (2, '', '');
    
	-- Finally we insert the Total Revenues with its value
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (3, 'Total Revenues', format(varTotalRevenues / 1000, 2));
	
    INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (4, 'Returns',  format(-varTotalReturns / 1000, 2));
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (5, 'COGS',  format(-varTotalCOGS/ 1000, 2));
	
    INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (6, 'GROSS PROFIT', (varTotalRevenues/1000 )+(-varTotalReturns/1000)+(-varTotalCOGS/1000) );
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (7, 'OPERATING EXPENSES',  '');
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (8, 'Administrative Expenses',  format(-varTotalADEXP/ 1000, 2));
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (9, 'Selling Expenses',  format(-varTotalSelling/ 1000, 2));
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (10, 'Other Expenses',  format(-varTotalOtherExp/ 1000, 2));
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (11, 'TOTAL OPERATING EXPENSES', (-varTotalADEXP/ 1000)+(-varTotalSelling/ 1000)+(-varTotalOtherExp/ 1000) );
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (12, 'OPERATING INCOME',  ((varTotalRevenues/1000 )+(-varTotalReturns/1000)+(-varTotalCOGS/1000)+ (-varTotalADEXP/ 1000)+(-varTotalSelling/ 1000)+(-varTotalOtherExp/ 1000)));
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (13, 'NONOPERATING INCOME',  '');
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (14, 'Total Other Income', format(varTotalOtherInc / 1000, 2));
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (15, 'TAXES',  '');
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (16, 'Income Tax',  format(-varTotalIncTax / 1000, 2));
        
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (17, 'Other Tax', format(-varTotalOtherTax / 1000, 2) );
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (18, 'TOTAL TAXES',  ((-varTotalIncTax / 1000)+(-varTotalOtherTax / 1000)));
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (19, 'TOTAL NONOPERATING INCOME',  (varTotalOtherInc / 1000)+(-varTotalIncTax / 1000)+(-varTotalOtherTax / 1000));
	INSERT INTO tmp_smedina2019_table 
		(profit_loss_line_number, label, amount)
  		VALUES (20, 'NET INCOME', (varTotalRevenues/1000 )+(-varTotalReturns/1000)+(-varTotalCOGS/1000)+ (-varTotalADEXP/ 1000)+(-varTotalSelling/ 1000)+(-varTotalOtherExp/ 1000)+
        (varTotalOtherInc / 1000)+(-varTotalIncTax / 1000)+(-varTotalOtherTax / 1000));
	
    
	END $$

DELIMITER ;

CALL smedina2019_sp(2018);

SELECT * FROM tmp_smedina2019_table;

--
# Balance Sheet
--
DROP PROCEDURE IF EXISTS `t21bs`;

DELIMITER $$
CREATE PROCEDURE `t21bs`(varCalendarYear YEAR)
    BEGIN
    
    
    SET @varCurrentAssetsDebit = (SELECT SUM(jeli.debit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id 
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE ss.statement_section_code = "CA"   
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
	
    SET @varCurrentAssetsDebitClean = (SELECT CASE WHEN @varCurrentAssetsDebit IS NULL or @varCurrentAssetsDebit = ' ' THEN 0 ELSE @varCurrentAssetsDebit END);
    
    SET @varCurrentAssetsCredit = (SELECT SUM(jeli.credit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE ss.statement_section_code = "CA"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
                            
	SET @varCurrentAssetsCreditClean = (SELECT CASE WHEN @varCurrentAssetsCredit IS NULL or @varCurrentAssetsCredit = ' ' THEN 0 ELSE @varCurrentAssetsCredit END);
                            
	SET @varTotalCurrentAssets = @varCurrentAssetsDebitClean - @varCurrentAssetsCreditClean;
                            
	SET @varFixedAssetsDebit = (SELECT SUM(jeli.debit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "FA"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
	
    SET @varFixedAssetsDebitClean = (SELECT CASE WHEN @varFixedAssetsDebit IS NULL or @varFixedAssetsDebit = ' ' THEN 0 ELSE @varFixedAssetsDebit END);
    
    SET @varFixedAssetsCredit = (SELECT SUM(jeli.credit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "FA"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
                            
	SET @varFixedAssetsCreditClean = (SELECT CASE WHEN @varFixedAssetsCredit IS NULL or @varFixedAssetsCredit = ' ' THEN 0 ELSE @varFixedAssetsCredit END);
                            
	SET @varTotalFixedAssets = @varFixedAssetsDebitClean - @varFixedAssetsCreditClean;
    
    SET @varDeferredAssetsDebit = (SELECT SUM(jeli.debit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "DA"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
	
    SET @varDeferredAssetsDebitClean = (SELECT CASE WHEN @varDeferredAssetsDebit IS NULL or @varDeferredAssetsDebit = ' ' THEN 0 ELSE @varDeferredAssetsDebit END);
    
    SET @varDeferredAssetsCredit = (SELECT SUM(jeli.credit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id 
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "DA"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
                            
	SET @varDeferredAssetsCreditClean = (SELECT CASE WHEN @varDeferredAssetsCredit IS NULL or @varDeferredAssetsCredit = ' ' THEN 0 ELSE @varDeferredAssetsCredit END);
                            
	SET @varTotalDeferredAssets = @varDeferredAssetsDebitClean - @varDeferredAssetsCreditClean;
    
	SET @varTotalAssets = @varTotalCurrentAssets + @varTotalFixedAssets + @varTotalDeferredAssets;
    
    SET @varCurrentLiabilitiesDebit = (SELECT SUM(jeli.debit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "CL"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
	
    SET @varCurrentLiabilitiesDebitClean = (SELECT CASE WHEN @varCurrentLiabilitiesDebit IS NULL or @varCurrentLiabilitiesDebit = ' ' THEN 0 ELSE @varCurrentLiabilitiesDebit END);
    
    SET @varCurrentLiabilitiesCredit = (SELECT SUM(jeli.credit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id 
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "CL"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
                            
	SET @varCurrentLiabilitiesCreditClean = (SELECT CASE WHEN @varCurrentLiabilitiesCredit IS NULL or @varCurrentLiabilitiesCredit = ' ' THEN 0 ELSE @varCurrentLiabilitiesCredit END);
                            
	SET @varTotalCurrentLiabilities = @varCurrentLiabilitiesCreditClean - @varCurrentLiabilitiesDebitClean;
    
    SET @varLongTermLiabilitiesDebit = (SELECT SUM(jeli.debit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "LLL"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
	
    SET @varLongTermLiabilitiesDebitClean = (SELECT CASE WHEN @varLongTermLiabilitiesDebit IS NULL or @varLongTermLiabilitiesDebit = ' ' THEN 0 ELSE @varLongTermLiabilitiesDebit END);
    
    SET @varLongTermLiabilitiesCredit = (SELECT SUM(jeli.credit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id 
                                 INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "LLL"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
                            
	SET @varLongTermLiabilitiesCreditClean = (SELECT CASE WHEN @varLongTermLiabilitiesCredit IS NULL or @varLongTermLiabilitiesCredit = ' ' THEN 0 ELSE @varLongTermLiabilitiesCredit END);
                            
	SET @varTotalLongTermLiabilities = @varLongTermLiabilitiesCreditClean - @varLongTermLiabilitiesDebitClean;
    
	SET @varDeferredliabilitiesDebit = (SELECT SUM(jeli.debit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "DL"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
	
    SET @varDeferredliabilitiesDebitClean = (SELECT CASE WHEN @varDeferredliabilitiesDebitD IS NULL or @varDeferredliabilitiesDebit = ' ' THEN 0 ELSE @varDeferredliabilitiesDebit END);
    
    SET @varDeferredliabilitiesCredit = (SELECT SUM(jeli.credit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "DL"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
                            
	SET @varDeferredliabilitiesCreditClean = (SELECT CASE WHEN @varDeferredliabilitiesCredit IS NULL or @varDeferredliabilitiesCredit = ' ' THEN 0 ELSE @varDeferredliabilitiesCredit END);
                            
	SET @varTotalDeferredliabilities = @varDeferrediabilitiesCreditClean - @varDeferredliabilitiesDebitClean;
    
    SET @varTotalLiabilities = @varTotalCurrentLiabilities + @varTotalLongTermLiabilities + @varTotalDeferredliabilities;

	SET @varEquityDebit = (SELECT SUM(jeli.debit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "EQ"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
	
    SET @varEquityDebitClean = (SELECT CASE WHEN @varEquityDebit IS NULL or @varEquityDebit = ' ' THEN 0 ELSE @varEquityDebit END);
    
    SET @varEquityCredit = (SELECT SUM(jeli.credit)
							FROM journal_entry_line_item as jeli
								INNER JOIN account as ac on ac.account_id = jeli.account_id    
								INNER JOIN journal_entry as je on je.journal_entry_id = jeli.journal_entry_id
                                INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
							WHERE statement_section_code = "EQ"    
								AND YEAR(je.entry_date) <= varCalendarYear
								AND (je.debit_credit_balanced) = 1
								AND (je.cancelled) = 0
							GROUP BY statement_section_code);
                            
	SET @varEquityCreditClean = (SELECT CASE WHEN @varEquityCredit IS NULL or @varEquityCredit = ' ' THEN 0 ELSE @varEquityCredit END);
                            
	SET @varTotalEquity = @varEquityCreditClean - @varEquityDebitClean;

	SET @varTotalLiabilitiesAndEquity = @varTotalLiabilities + @varTotalEquity;
					
	SELECT varCalendarYear as Year, 'BALANCE SHEET' AS Item, '$' AS Balance
		FROM journal_entry 		AS je
		WHERE YEAR(je.entry_date) = varCalendarYear
        
	UNION
        
	SELECT ' ', 'Current Assets', FORMAT(@varTotalCurrentAssets/1000,2)
    
	UNION

	SELECT ' ', 'Fixed Assets', FORMAT(@varTotalFixedAssets/1000,2)
	
    UNION
	
	SELECT ' ', 'Deferred Assets', FORMAT(@varTotalDeferredAssets/1000,2)

	UNION
    
	SELECT ' ', 'Total Assets', FORMAT(@varTotalAssets/1000,2)
    
    UNION

	SELECT ' ', 'Current Liabilities', FORMAT(@varTotalCurrentLiabilities/1000,2)

	UNION

	SELECT ' ', 'Long-Term Liabilities',FORMAT(@varTotalLongTermLiabilities/1000,2)
    
    UNION
    
	SELECT ' ', 'Deferred Liabilities',FORMAT(@varTotalDeferredliabilities/1000,2)
    
    UNION
    
	SELECT ' ', 'Total Liabilities', FORMAT(@varTotalLiabilities/1000,2)

	UNION
    
	SELECT ' ', 'Equity',FORMAT(@varTotalEquity/1000, 2)

	UNION
    
	SELECT ' ', 'Total Liabilities & Equity', FORMAT(@varTotalLiabilitiesAndEquity/1000,2);

    END $$

DELIMITER ;	


# For Balance Sheet
CALL t21bs(2018);