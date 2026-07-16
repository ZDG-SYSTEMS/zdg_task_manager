<?php

namespace App\Enums;

enum AttachmentKind: string
{
    case Quotation = 'quotation';
    case Invoice = 'invoice';
    case Receipt = 'receipt';
}
