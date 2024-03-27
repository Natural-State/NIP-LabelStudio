# Generated by Django 3.2.23 on 2024-03-19 17:38

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('ml_models', '0004_modelrun_job_id'),
    ]

    operations = [
        migrations.AddField(
            model_name='modelrun',
            name='predictions_updated_at',
            field=models.DateTimeField(default=None, null=True, verbose_name='predictions updated at'),
        ),
        migrations.AlterField(
            model_name='modelrun',
            name='triggered_at',
            field=models.DateTimeField(default=None, null=True, verbose_name='triggered at'),
        ),
    ]