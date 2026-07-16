<?php

/**
 * Scans source and copy files for emoji characters, which are forbidden
 * project-wide (see CLAUDE.md hard conventions). Exits non-zero when any
 * emoji is found so it can gate commits and CI.
 *
 * Usage:
 *   php scripts/check_no_emoji.php [path ...]
 * With no arguments it scans the backend and frontend source trees.
 */
$defaultTargets = [
    __DIR__.'/../zdg_tasks_backend/app',
    __DIR__.'/../zdg_tasks_backend/database',
    __DIR__.'/../zdg_tasks_backend/routes',
    __DIR__.'/../zdg_tasks_backend/tests',
    __DIR__.'/../zdg_tasks_backend/resources',
    __DIR__.'/../zdg_tasks_frontend/lib',
    __DIR__.'/../zdg_tasks_frontend/test',
];

$extensions = ['php', 'dart', 'md', 'yaml', 'yml', 'json', 'js', 'blade.php', 'html', 'css'];

// Unicode blocks that render as emoji. Deliberately excludes general
// punctuation and arrows so legitimate prose is never flagged.
$emojiPattern = '/[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{1F1E6}-\x{1F1FF}\x{2B00}-\x{2BFF}\x{FE0F}\x{200D}\x{20E3}]/u';

$targets = array_slice($argv, 1) ?: $defaultTargets;
$violations = [];

$scanFile = function (string $path) use ($emojiPattern, &$violations): void {
    $lines = @file($path);
    if ($lines === false) {
        return;
    }
    foreach ($lines as $number => $line) {
        if (preg_match($emojiPattern, $line)) {
            $violations[] = $path.':'.($number + 1);
        }
    }
};

foreach ($targets as $target) {
    if (is_file($target)) {
        $scanFile($target);
        continue;
    }
    if (! is_dir($target)) {
        continue;
    }
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($target, FilesystemIterator::SKIP_DOTS)
    );
    foreach ($iterator as $file) {
        $name = $file->getFilename();
        foreach ($extensions as $extension) {
            if (str_ends_with($name, '.'.$extension)) {
                $scanFile($file->getPathname());
                break;
            }
        }
    }
}

if ($violations !== []) {
    fwrite(STDERR, "Emoji found (forbidden by project convention):\n");
    foreach ($violations as $violation) {
        fwrite(STDERR, '  '.$violation."\n");
    }
    exit(1);
}

echo "No emoji found.\n";
