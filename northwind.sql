  -- 📊 PROYECTO SQL: Análisis de Ventas con Northwind
-- Autor: Joaquín Fernández
-- Base de Datos: Northwind
-- Objetivo: Practicar SQL en un contexto de ventas simulado con consultas de negocio reales

-- 1. Listado de productos
SELECT ProductID, ProductName, UnitPrice, UnitsInStock
FROM Products;

-- 2. Clientes por país
SELECT DISTINCT Country FROM Customers;

-- 3. Ordenar productos por precio
SELECT ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC;

-- =============================
-- 🔹 SECCIÓN 3: JOINs
-- =============================

-- 4. Productos y sus categorías
SELECT P.ProductName, C.CategoryName
FROM Products P
JOIN Categories C ON P.CategoryID = C.CategoryID;

-- 5. Órdenes con nombre del cliente y empleado
SELECT O.OrderID, C.CompanyName, E.FirstName + ' ' + E.LastName AS Empleado
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN Employees E ON O.EmployeeID = E.EmployeeID;

-- =============================
-- 🔹 SECCIÓN 4: Funciones Agregadas
-- =============================

-- 6. Total de ventas por cliente
SELECT C.CompanyName, SUM(OD.UnitPrice * OD.Quantity) AS TotalGastado
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.CompanyName
ORDER BY TotalGastado DESC;

-- 7. Promedio de unidades por pedido
SELECT AVG(Quantity) AS PromedioUnidades
FROM [Order Details];

-- =============================
-- 🔹 SECCIÓN 5: Subconsultas
-- =============================

-- 8. Clientes que hayan hecho más de 10 pedidos
SELECT CompanyName
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Orders
    GROUP BY CustomerID
    HAVING COUNT(OrderID) > 10
);

-- =============================
-- 🔹 SECCIÓN 6: Funciones de ventana
-- =============================

-- 9. Ranking de empleados por total de ventas
SELECT E.EmployeeID, E.FirstName + ' ' + E.LastName AS Empleado,
       SUM(OD.UnitPrice * OD.Quantity) AS TotalVendido,
       RANK() OVER (ORDER BY SUM(OD.UnitPrice * OD.Quantity) DESC) AS Ranking
FROM Employees E
JOIN Orders O ON E.EmployeeID = O.EmployeeID
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY E.EmployeeID, E.FirstName, E.LastName;

-- =============================
-- 🔹 SECCIÓN 7: Vistas y Procedimientos
-- =============================

-- 10. Crear una vista de productos con stock bajo
CREATE VIEW vw_StockBajo AS
SELECT ProductName, UnitsInStock
FROM Products
WHERE UnitsInStock < 10;

-- 11. Procedimiento para ver ventas por país
CREATE PROCEDURE VentasPorPais
AS
BEGIN
    SELECT C.Country, SUM(OD.UnitPrice * OD.Quantity) AS TotalVentas
    FROM Orders O
    JOIN Customers C ON O.CustomerID = C.CustomerID
    JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY C.Country;
END;

-- =============================
-- 🔹 SECCIÓN 8: Extras
-- =============================

-- 12. Trigger para auditar productos desactivados
CREATE TRIGGER trg_ProductoDesactivado
ON Products
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted i JOIN deleted d ON i.ProductID = d.ProductID WHERE d.Discontinued = 0 AND i.Discontinued = 1)
    BEGIN
        PRINT 'Producto desactivado registrado.';
    END
END;
