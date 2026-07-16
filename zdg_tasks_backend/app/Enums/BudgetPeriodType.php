<?php

namespace App\Enums;

enum BudgetPeriodType: string
{
    case Weekly = 'weekly';
    case Monthly = 'monthly';
    case Quarterly = 'quarterly';
    case Annual = 'annual';
}
