import pandas as pd


def transform_uppercase(data: pd.DataFrame) -> pd.DataFrame:
    """
    Transform the data to uppercase.
    Args:
        data (DataFrame): Data to be transformed.

    Returns:
        (DataFrame) Transformed data to uppercase.
    """
    return data.applymap(lambda row: row.upper())