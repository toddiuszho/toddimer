@echo off
rem
rem Query EHMS
rem
rem qe <cfg> <action> <params>
rem

setlocal

if "%1x" == "helpx"     goto :_Help
if "%1x" == "x"         goto :_Help
if "%2x" == "x"         goto :_Help
if "%2x" == "constituentsx"    goto :_constituents
if "%2x" == "employerx" goto :_employer
if "%2x" == "memberx"   goto :_member
if "%2x" == "memberloginx"     goto :_memberlogin
if "%2x" == "pageauthx" goto :_pageauth
if "%2x" == "rolesx"    goto :_roles
if "%2x" == "rolex"     goto :_role
if "%2x" == "rolesofx"  goto :_rolesof
if "%2x" == "tenantsx"  goto :_tenants
if "%2x" == "tenantx"   goto :_tenant

:_Help
if "%2x" == "constituentsx"    goto :_constituents_Help
if "%2x" == "employerx" goto :_employer_Help
if "%2x" == "memberx"   goto :_member_Help
if "%2x" == "memberloginx"     goto :_memberlogin_Help
if "%2x" == "pageauthx" goto :_pageauth_Help
if "%2x" == "rolesx"    goto :_roles_Help
if "%2x" == "rolex"     goto :_role_Help
if "%2x" == "rolesofx"  goto :_rolesof_Help
if "%2x" == "tenantsx"  goto :_tenants_Help
if "%2x" == "tenantx"   goto :_tenant_Help

echo usage: qe ^<cfg^> ^<action^> ^<params^>
echo.
echo Actions:
echo constituents
echo           -- list all constituents and roles within
echo employer  -- info on an employer by employerId
echo member    -- info on a member by memberId
echo memberlogin
echo           -- info on a member by username
echo pageauth  -- find page authorization expressions
echo roles     -- list all roles and constituent they belong to
echo role      -- find users by role and other roles they have
echo rolesof   -- find all roles by username
echo tenants   -- list all tenants
echo tenant    -- info on a tenant by tenantId
echo.
echo For help on a specifc action, type: qe help ^<action^> -OR- qe ^<action^> help
goto :_End

:_role
if "%3x" == "x"         goto :_role_Help
if "%3x" == "helpx"     goto :_role_Help
set QUERY="SELECT u.username, r.role FROM `user` u, userrole ur, roles r WHERE u.userId = ur.userId and ur.roleId = r.roleId AND u.userId IN (SELECT u.userId FROM `user` u, userrole ur, roles r WHERE u.userId = ur.userId AND ur.roleId = r.roleId AND r.role = '%3') ORDER BY u.username"
goto :_Call

:_role_Help
echo ACTION hasrole: qe ^<cfg^> role ^<rolename^>
goto :_End

:_rolesof
if "%3x" == "x"        goto :_rolesof_Help
if "%3x" == "helpx"    goto :_rolesof_Help
set QUERY="SELECT u.username, r.role FROM `user` u, userrole ur, roles r WHERE u.userId = ur.userId and ur.roleId = r.roleId AND u.username = '%3' ORDER BY r.role"
goto :_Call

:_rolesof_Help
echo ACTION rolesof: qe ^<cfg^> rolesof ^<username^>
goto :_End

:_roles
set QUERY="SELECT r.role, c.name as constituent FROM roles r, constituent c WHERE c.constituentId = r.constituentId ORDER BY r.role"
goto :_Call

:_roles_Help
echo ACTION rolesof: qe ^<cfg^> roles
goto :_End

:_constituents
set QUERY="SELECT c.name as constituent, r.role FROM roles r, constituent c WHERE c.constituentId = r.constituentId ORDER BY c.name, r.role"
goto :_Call

:_constituents_Help
echo ACTION constituents: qe ^<cfg^> constituents
goto :_End

:_tenants
set QUERY="SELECT t.tenantId, t.name, t.url, t.logoimage FROM tenant t ORDER BY t.tenantId"
goto :_Call

:_tenants_Help
echo ACTION tenants: qe ^<cfg^> tenants
goto :_End

:_tenant
if "%3x" == "x"        goto :_tenant_Help
if "%3x" == "helpx"    goto :_tenant_Help

echo Tenant Info
set QUERY="SELECT t.tenantId, t.name, t.url, t.logoimage FROM tenant t WHERE t.tenantId = %3"
call query.cmd %QUERY% %1

echo.
echo Configurators
set QUERY="SELECT u.userId, c.configuratorId, u.username, c.name, r.role FROM `user` u, userrole ur, roles r, configurator c WHERE u.userId = ur.userId AND ur.roleId = r.roleId AND (c.userId = u.userId AND c.tenantId = %3) ORDER BY u.username, r.role"
call query.cmd %QUERY% %1

echo.
echo Brokers
set QUERY="SELECT u.userId, b.brokerId, u.username, b.name, r.role FROM `user` u, userrole ur, roles r, broker b WHERE u.userId = ur.userId AND ur.roleId = r.roleId AND (b.userId = u.userId AND b.tenantId = %3) ORDER BY u.username, r.role"
call query.cmd %QUERY% %1

echo.
echo Employers
set QUERY="SELECT e.employerId, e.name, e.brokerId, e.homeimage FROM employer e WHERE (e.tenantId = %3) ORDER BY e.name"
call query.cmd %QUERY% %1

goto :_End

:_tenant_Help
echo ACTION tenant: qe ^<cfg^> tenants ^<tenantId^>
goto :_End

:_member
if "%3x" == "x"        goto :_member_Help
if "%3x" == "helpx"    goto :_member_Help
set QUERY="SELECT u.userId, m.memberId, u.username, concat(m.firstname, ' ', m.lastname) as name, m.employerId, e.tenantId, m.termdate FROM member m, `user` u, employer e WHERE u.userId = m.userId AND m.memberId = %3 AND m.employerId = e.employerId"
goto :_Call

:_member_Help
echo ACTION member: qe ^<cfg^> member ^<memberId^>
goto :_End
goto :_End

:_memberlogin
if "%3x" == "x"        goto :_memberlogin_Help
if "%3x" == "helpx"    goto :_memberlogin_Help
set QUERY="SELECT u.userId, m.memberId, u.username, concat(m.firstname, ' ', m.lastname) as name, m.employerId, e.tenantId, m.termdate FROM member m, `user` u, employer e WHERE u.userId = m.userId AND u.username = '%3' AND m.employerId = e.employerId"
goto :_Call

:_memberlogin_Help
echo ACTION member: qe ^<cfg^> memberlogin ^<username^>
goto :_End
goto :_End

:_employer
if "%3x" == "x"        goto :_employer_Help
if "%3x" == "helpx"    goto :_employer_Help

echo Employer Info
set QUERY="SELECT e.employerId, e.name, e.brokerId, e.organizationId, e.tenantId, e.homeimage FROM employer e WHERE e.employerId = %3"
call query.cmd %QUERY% %1

echo.
echo Representatives
set QUERY="SELECT u.userId, r.repId, u.username, concat(r.firstname, ' ', r.lastname) as name, r.organizationId FROM employer e, employer_representative r, employer_representative_employer ere, `user` u WHERE ere.employerId = %3 AND ere.repId = r.repId and r.userId = u.userId and ere.employerId = e.employerId"
call query.cmd %QUERY% %1

goto :_End

:_employer_Help
echo ACTION employer: qe ^<cfg^> employer ^<employerId^>
goto :_End

:_pageauth
if "%3x" == "x"        goto :_pageauth_Help
if "%3x" == "helpx"    goto :_pageauth_Help
set QUERY="SELECT p.viewId, p.expr FROM page_auth p WHERE p.viewId LIKE '%%%%%3%%%%'"
set FLAG=-E
goto :_Call

:_pageauth_Help
echo ACTION employer: qe ^<cfg^> pageauth ^<view^>
echo view: substring to match views with
goto :_End

:_Call
call query.cmd %QUERY% %1 %FLAG%
goto :_End

:_End
endlocal
