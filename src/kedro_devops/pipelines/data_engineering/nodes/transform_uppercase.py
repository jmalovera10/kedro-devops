import pandas as pd


def transform_uppercase(data: pd.DataFrame) -> pd.DataFrame:
    """
    Transform a lowercase dataframe to uppercase.

    Args:
        data (pd.DataFrame): A raw dataframe

    Returns:
        pd.DataFrame: An uppercase dataframe
    """
    return data.applymap(lambda x: x.upper())
