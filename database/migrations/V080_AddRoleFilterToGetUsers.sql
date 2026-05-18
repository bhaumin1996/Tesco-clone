-- V080_AddRoleFilterToGetUsers.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Add @Role filtering support to proc_Admin_GetUsers.
-- Dependencies: V079

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

ALTER PROCEDURE proc_Admin_GetUsers
    @Search     NVARCHAR(256) = NULL,
    @Role       NVARCHAR(100) = NULL,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        WITH UserList AS
        (
            SELECT
                u.Id,
                u.FirstName,
                u.LastName,
                u.Email,
                u.PhoneNumber,
                us.Name AS StatusName,
                u.FailedLoginAttempts,
                u.LockedUntil,
                u.CreatedOn,
                u.ModifiedOn
            FROM t.tblUser u
            INNER JOIN m.tblUserStatus us ON us.Id = u.StatusId
            WHERE u.IsDeleted = 0
              AND (@Search IS NULL
                   OR u.Email      LIKE '%' + @Search + '%'
                   OR u.FirstName  LIKE '%' + @Search + '%'
                   OR u.LastName   LIKE '%' + @Search + '%')
              AND (@Role IS NULL
                   OR EXISTS (
                       SELECT 1 
                       FROM t.tblUserRole ur
                       INNER JOIN m.tblRole r ON r.Id = ur.RoleId
                       WHERE ur.UserId = u.Id AND ur.IsDeleted = 0 AND r.Name = @Role
                   ))
        ),
        UserListWithCount AS
        (
            SELECT 
                ul.*,
                COUNT(1) OVER () AS TotalCount
            FROM UserList ul
            ORDER BY ul.CreatedOn DESC
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY
        )
        SELECT 
            ul.*,
            (
                SELECT STRING_AGG(r.Name, ',')
                FROM t.tblUserRole ur
                INNER JOIN m.tblRole r ON r.Id = ur.RoleId
                WHERE ur.UserId = ul.Id AND ur.IsDeleted = 0
            ) AS RoleNames
        FROM UserListWithCount ul;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetUsers', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V080')
    INSERT INTO t.tblMigration (Version, Description)
    VALUES ('V080', 'AddRoleFilterToGetUsers');
GO
