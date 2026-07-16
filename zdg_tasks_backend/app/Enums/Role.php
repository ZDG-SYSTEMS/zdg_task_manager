<?php

namespace App\Enums;

enum Role: string
{
    case Technical = 'technical';
    case Director = 'director';
    case Dof = 'dof';
    case CompanyFinance = 'company_finance';
    case DeptHead = 'dept_head';
    case Auditor = 'auditor';
}
