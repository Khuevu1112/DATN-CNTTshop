use shopDB
USE ShopDB;
GO

CREATE TABLE INSTALLMENT_PLAN (
    id INT IDENTITY(1,1) PRIMARY KEY,
    months INT NOT NULL UNIQUE,
    interest_rate DECIMAL(5,2) NOT NULL,
    active BIT NOT NULL DEFAULT 1
);
GO

INSERT INTO INSTALLMENT_PLAN(months, interest_rate, active)
VALUES
    (3, 0.00, 1),
    (6, 1.50, 1),
    (9, 2.50, 1),
    (12, 3.50, 1),
    (18, 5.00, 1),
    (24, 7.00, 1);
GO

CREATE TABLE INSTALLMENT_ORDER (
    id INT IDENTITY(1,1) PRIMARY KEY,

    user_id INT NULL,
    product_id INT NOT NULL,
    variant_id INT NULL,

    product_name NVARCHAR(255) NOT NULL,
    selected_options NVARCHAR(1000) NULL,
    quantity INT NOT NULL DEFAULT 1,

    months INT NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,

    price DECIMAL(18,2) NOT NULL,
    down_payment DECIMAL(18,2) NOT NULL DEFAULT 0,
    loan_amount DECIMAL(18,2) NOT NULL,
    total_interest DECIMAL(18,2) NOT NULL,
    monthly_payment DECIMAL(18,2) NOT NULL,
    total_payment DECIMAL(18,2) NOT NULL,

    customer_name NVARCHAR(150) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(150) NULL,
    customer_address NVARCHAR(500) NOT NULL,
    identity_number VARCHAR(20) NOT NULL,

    status NVARCHAR(30) NOT NULL DEFAULT N'PENDING',
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO


IF OBJECT_ID('dbo.PRODUCT_REVIEW', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PRODUCT_REVIEW (
        id          INT IDENTITY(1,1) NOT NULL,
        product_id  INT NOT NULL,
        user_id     INT NOT NULL,
        rating      INT NOT NULL,
        content     NVARCHAR(1000) NOT NULL,
        is_visible  BIT NOT NULL CONSTRAINT DF_PRODUCT_REVIEW_VISIBLE DEFAULT 1,
        created_at  DATETIME2 NOT NULL CONSTRAINT DF_PRODUCT_REVIEW_CREATED DEFAULT SYSDATETIME(),
        updated_at  DATETIME2 NULL,

        CONSTRAINT PK_PRODUCT_REVIEW PRIMARY KEY (id),
        CONSTRAINT CK_PRODUCT_REVIEW_RATING CHECK (rating BETWEEN 1 AND 5),
        CONSTRAINT CK_PRODUCT_REVIEW_CONTENT CHECK (LEN(LTRIM(RTRIM(content))) >= 10),
        CONSTRAINT UQ_PRODUCT_REVIEW_PRODUCT_USER UNIQUE (product_id, user_id),
        CONSTRAINT FK_PRODUCT_REVIEW_PRODUCT FOREIGN KEY (product_id) REFERENCES dbo.PRODUCT(id),
        CONSTRAINT FK_PRODUCT_REVIEW_USER FOREIGN KEY (user_id) REFERENCES dbo.[USER](id)
    );

    CREATE INDEX IX_PRODUCT_REVIEW_PRODUCT_VISIBLE_CREATED
        ON dbo.PRODUCT_REVIEW(product_id, is_visible, created_at DESC);
END;
GO