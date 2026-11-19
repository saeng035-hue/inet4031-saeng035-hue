
import csv
import random
from datetime import datetime, timedelta, timezone
from pathlib import Path

random.seed(4031)

output = Path(__file__).parent / "output"
output.mkdir(exist_ok=True)

categories = ["Network", "Database", "Application", "Security", "Hardware"]
statuses = ["open", "closed"]

start_date = datetime(2026, 7, 1, tzinfo=timezone.utc)
end_date = datetime(2026, 11, 15, tzinfo=timezone.utc)

file_path = output / "tickets.csv"

with file_path.open("w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow([
        "id", "category", "status", "created_at",
        "resolved_at", "resolution_hours"
    ])

    for ticket_id in range(1, 10004):
        created = start_date + timedelta(
            seconds=random.randint(
                0, int((end_date - start_date).total_seconds())
            )
        )

        category = random.choice(categories)
        status = random.choices(statuses, weights=[30, 70])[0]

        if status == "closed":
            hours = round(random.uniform(1, 120), 2)
            resolved = created + timedelta(hours=hours)
            resolved_at = resolved.isoformat()
        else:
            hours = ""
            resolved_at = ""

        writer.writerow([
            ticket_id,
            category,
            status,
            created.isoformat(),
            resolved_at,
            hours
        ])

print(f"Created {file_path} with 10003 synthetic tickets.")
