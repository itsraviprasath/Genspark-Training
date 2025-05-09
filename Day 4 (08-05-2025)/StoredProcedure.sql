-- 1. SELECT Query Using TRY_CAST

SELECT * 
FROM TEST_Products 
WHERE TRY_CAST(json_value(details, '$.spec.cpu') AS nvarchar(20)) = 'i7';
GO

-- 2. Stored Procedure with Output Parameter

CREATE PROCEDURE proc_FilterProducts(@pcpu VARCHAR(20), @pcount INT OUTPUT)
AS
BEGIN
    -- Set the output parameter with the count of records
    SET @pcount = (
        SELECT COUNT(*)
        FROM TEST_Products
        WHERE TRY_CAST(json_value(details, '$.spec.cpu') AS nvarchar(20)) = @pcpu
    );
END;
GO

-- Call the stored procedure and print the result
BEGIN
    DECLARE @count INT;
    EXEC proc_FilterProducts 'i7', @count OUTPUT;
    PRINT CONCAT('The number of computers is ', @count);
END;
GO

-- 3. Bulk Insert Using CSV File
-- Create Table for Bulk Insert
CREATE TABLE TEST_People (
    id INT PRIMARY KEY,
    name VARCHAR(20),
    age INT
);
GO

-- Create or Alter the Procedure for Bulk Insert
CREATE OR ALTER PROCEDURE proc_BulkInsert(@filepath NVARCHAR(500))
AS
BEGIN
    DECLARE @insertQuery NVARCHAR(MAX);
    SET @insertQuery = 'BULK INSERT TEST_People 
                        FROM ''' + @filepath + '''
                        WITH (
                            FIRSTROW = 2,
                            FIELDTERMINATOR = '','',
                            ROWTERMINATOR = ''\n''
                        )';
    EXEC sp_executesql @insertQuery;
END;
GO

-- Execute Bulk Insert Procedure
EXEC proc_BulkInsert 'C:\Users\raviprasathr\Downloads\Genspark-Training\08-05-2025\Data.csv';

-- Verify the Inserted Data
SELECT * FROM TEST_People;
GO

-- 4. Using Built-in Stored Procedures (Example)
-- Get metadata for the "authors" table
EXEC sp_help authors;
GO

-- 5. Storing Bulk Insert Logs
-- Create Table for Bulk Insert Logs
CREATE TABLE TEST_BulkInsertLog (
    LogId INT IDENTITY(1,1) PRIMARY KEY,
    FilePath NVARCHAR(1000),
    Status NVARCHAR(50) CONSTRAINT chk_status CHECK(Status IN ('Success', 'Failed')),
    Message NVARCHAR(1000),
    InsertedOn DATETIME DEFAULT GETDATE()
);
GO

-- Create or Alter Procedure to Log Bulk Insert Results
CREATE OR ALTER PROCEDURE proc_BulkInsert(@filepath NVARCHAR(500))
AS
BEGIN
    BEGIN TRY
        DECLARE @insertQuery NVARCHAR(MAX);
        SET @insertQuery = 'BULK INSERT TEST_People 
                            FROM ''' + @filepath + '''
                            WITH (
                                FIRSTROW = 2,
                                FIELDTERMINATOR = '','',
                                ROWTERMINATOR = ''\n''
                            )';
        EXEC sp_executesql @insertQuery;

        -- Log success message
        INSERT INTO TEST_BulkInsertLog(FilePath, Status, Message)
        VALUES(@filepath, 'Success', 'Bulk Insert Completed');
    END TRY
    BEGIN CATCH
        -- Log failure message with error details
        INSERT INTO TEST_BulkInsertLog(FilePath, Status, Message)
        VALUES(@filepath, 'Failed', ERROR_MESSAGE());
    END CATCH;
END;
GO

-- Execute the Bulk Insert with Logging
EXEC proc_BulkInsert 'C:\Users\raviprasathr\Downloads\Genspark-Training\08-05-2025\Data.csv';

-- View the Log Results
SELECT * FROM TEST_BulkInsertLog;

-- Clear the TEST_People table after bulk insert
TRUNCATE TABLE TEST_People;
GO

-- 6. Common Table Expressions (CTEs)
-- Simple CTE to Combine First and Last Names of Authors
WITH cteAuthors AS (
    SELECT au_id, CONCAT(au_fname, ' ', au_lname) AS Author_Name
    FROM authors
)
SELECT * FROM cteAuthors;
GO

-- CTE for Pagination
DECLARE @page INT = 2, @pageSize INT = 10;
WITH PaginationBooks AS (
    SELECT title_id, title, price, 
           ROW_NUMBER() OVER (ORDER BY price DESC) AS RowNum
    FROM titles
)
SELECT * 
FROM PaginationBooks
WHERE RowNum BETWEEN ((@page - 1) * @pageSize + 1) AND (@page * @pageSize);
GO

-- Create a Stored Procedure for Pagination
CREATE PROCEDURE proc_PaginationBooks (@page INT = 1, @pageSize INT = 10)
AS
BEGIN
    WITH PaginationBooks AS (
        SELECT title_id, title, price, 
               ROW_NUMBER() OVER (ORDER BY price DESC) AS RowNum
        FROM titles
    )
    SELECT * 
    FROM PaginationBooks
    WHERE RowNum BETWEEN ((@page - 1) * @pageSize + 1) AND (@page * @pageSize);
END;
GO

-- Execute the Pagination Stored Procedure
EXEC proc_PaginationBooks 2, 5;
GO

-- 7. Advanced Pagination with OFFSET and FETCH
SELECT title_id, title, price
FROM titles
ORDER BY price DESC
OFFSET 10 ROWS 
FETCH NEXT 10 ROWS ONLY;
GO

-- 8. Scalar Function: Calculate Tax
-- Create Scalar Function to Calculate Tax
CREATE FUNCTION fn_CalculateTax(@baseprice FLOAT, @tax FLOAT)
RETURNS FLOAT
AS
BEGIN
    RETURN (@baseprice + (@baseprice * @tax / 100));
END;
GO

-- Test the Scalar Function
SELECT dbo.fn_CalculateTax(1000, 10);
SELECT title, dbo.fn_CalculateTax(price, 12) AS Taxed_Price FROM titles;
GO

-- 9. Table-Valued Functions (TVF)
-- Create a TVF that Returns Books with Price Greater Than or Equal to a Given Value
CREATE FUNCTION fn_tableSample(@inprice FLOAT)
RETURNS TABLE
AS
BEGIN
    RETURN (
        SELECT title, price 
        FROM titles 
        WHERE price >= @inprice
    );
END;
GO

-- Test the Table-Valued Function
SELECT * FROM dbo.fn_tableSample(10);
GO

-- 10. Older Approach to TVF (Using @Result Table Variable)
CREATE FUNCTION fn_tableSampleOld(@minprice FLOAT)
RETURNS @Result TABLE (Book_Name NVARCHAR(100), price FLOAT)
AS
BEGIN
    INSERT INTO @Result
    SELECT title, price 
    FROM titles 
    WHERE price >= @minprice;

    RETURN;
END;
GO

-- Test the Older TVF
SELECT * FROM dbo.fn_tableSampleOld(10);
GO
