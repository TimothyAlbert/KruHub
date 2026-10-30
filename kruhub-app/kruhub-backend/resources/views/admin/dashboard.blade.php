<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KruHub Admin Dashboard</title>
    <style>
        :root {
            --bg: #0f172a;
            --panel: #111827;
            --panel-soft: #1f2937;
            --card: #1e293b;
            --muted: #94a3b8;
            --text: #e2e8f0;
            --primary: #38bdf8;
            --success: #22c55e;
            --warning: #fbbf24;
            --danger: #f87171;
            --border: rgba(148, 163, 184, 0.2);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(180deg, var(--bg) 0%, #020817 100%);
            color: var(--text);
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 32px 20px 48px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
            gap: 16px;
        }

        .header h1 {
            margin: 0;
            font-size: 2rem;
        }

        .badge {
            background: rgba(56, 189, 248, 0.12);
            border: 1px solid var(--border);
            color: var(--primary);
            padding: 8px 14px;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 700;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 18px;
            margin-bottom: 28px;
        }

        .card {
            background: rgba(17, 24, 39, 0.95);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 20px;
            box-shadow: 0 8px 22px rgba(15, 23, 42, 0.25);
        }

        .card .label {
            color: var(--muted);
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
        }

        .card .value {
            margin-top: 12px;
            font-size: 2rem;
            font-weight: 800;
        }

        .card.primary { border-color: rgba(56, 189, 248, 0.5); }
        .card.success { border-color: rgba(34, 197, 94, 0.45); }
        .card.warning { border-color: rgba(251, 191, 36, 0.45); }
        .card.danger { border-color: rgba(248, 113, 113, 0.45); }

        .content-grid {
            display: grid;
            grid-template-columns: 1.5fr 1fr;
            gap: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px;
        }

        th, td {
            text-align: left;
            padding: 12px 10px;
            border-bottom: 1px solid var(--border);
            vertical-align: top;
        }

        th {
            color: var(--muted);
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.06em;
        }

        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 999px;
            font-size: 0.74rem;
            font-weight: 700;
        }

        .status.active { background: rgba(34, 197, 94, 0.12); color: #86efac; }
        .status.pending { background: rgba(251, 191, 36, 0.12); color: #fcd34d; }
        .status.completed { background: rgba(56, 189, 248, 0.12); color: #7dd3fc; }
        .status.blocked { background: rgba(248, 113, 113, 0.12); color: #fca5a5; }

        .muted {
            color: var(--muted);
        }

        @media (max-width: 768px) {
            .content-grid {
                grid-template-columns: 1fr;
            }

            .header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Admin Dashboard</h1>
            <span class="badge">KruHub Backup Admin</span>
        </div>

        <div class="grid">
            <div class="card primary">
                <div class="label">Total Project</div>
                <div class="value">{{ $stats['total_projects'] }}</div>
            </div>
            <div class="card success">
                <div class="label">Project Aktif</div>
                <div class="value">{{ $stats['active_projects'] }}</div>
            </div>
            <div class="card warning">
                <div class="label">Total Member</div>
                <div class="value">{{ $stats['total_members'] }}</div>
            </div>
            <div class="card danger">
                <div class="label">Task Pending</div>
                <div class="value">{{ $stats['pending_tasks'] }}</div>
            </div>
        </div>

        <div class="grid">
            <div class="card">
                <div class="label">Total Task</div>
                <div class="value">{{ $stats['total_tasks'] }}</div>
            </div>
            <div class="card">
                <div class="label">Task Selesai</div>
                <div class="value">{{ $stats['completed_tasks'] }}</div>
            </div>
            <div class="card">
                <div class="label">Total Asset</div>
                <div class="value">{{ $stats['total_assets'] }}</div>
            </div>
            <div class="card">
                <div class="label">Asset Ready</div>
                <div class="value">{{ $stats['available_assets'] }}</div>
            </div>
        </div>

        <div class="content-grid">
            <div class="card">
                <h2 style="margin: 0 0 12px;">Project Terbaru</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Project</th>
                            <th>Status</th>
                            <th>Member</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($projects as $project)
                            <tr>
                                <td>
                                    <strong>{{ $project->name }}</strong><br>
                                    <span class="muted">{{ $project->team_code }}</span>
                                </td>
                                <td>
                                    <span class="status {{ strtolower($project->project_status ?? 'active') }}">
                                        {{ $project->project_status ?? 'Active' }}
                                    </span>
                                </td>
                                <td>{{ $project->members_count }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="3" class="muted">Belum ada data project.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <div class="card">
                <h2 style="margin: 0 0 12px;">Task Terbaru</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Judul</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($recentTasks as $task)
                            <tr>
                                <td>
                                    <strong>{{ $task->title }}</strong><br>
                                    <span class="muted">{{ $task->team?->name ?? 'Project tidak diketahui' }}</span>
                                </td>
                                <td>
                                    <span class="status {{ strtolower(str_replace(' ', '-', $task->status)) }}">
                                        {{ $task->status }}
                                    </span>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="2" class="muted">Belum ada task.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card" style="margin-top: 20px;">
            <h2 style="margin: 0 0 12px;">Asset Terbaru</h2>
            <table>
                <thead>
                    <tr>
                        <th>Asset</th>
                        <th>Kategori</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($recentAssets as $asset)
                        <tr>
                            <td>
                                <strong>{{ $asset->name }}</strong><br>
                                <span class="muted">{{ $asset->team?->name ?? 'Project tidak diketahui' }}</span>
                            </td>
                            <td>{{ $asset->category ?? '-' }}</td>
                            <td>
                                <span class="status {{ strtolower(str_replace(' ', '-', $asset->status)) }}">
                                    {{ $asset->status }}
                                </span>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="3" class="muted">Belum ada asset.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
