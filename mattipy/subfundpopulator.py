import pandas as pd

def read_subfunds(file_name, year):
    df = pd.read_excel(file_name, sheet_name='SF', usecols=[2, 3], header=None, skiprows=1)
    df.columns = ['SubfundName', 'SubfundType']
    df['Year'] = year
    return df

def remove_duplicates(df):
    return df.groupby(['SubfundName', 'SubfundType'])['Year'].apply(list).reset_index()

def main():
    all_subfunds = pd.DataFrame(columns=['SubfundName', 'SubfundType', 'Year'])

    for year in range(1997, 2019):
        if year < 2008:
            file_name = f"/users/matthias/Documents/GitHub/engx-project-group20/skjölin frá Birgi/Files/{year}.xlsx"
        else:
            file_name = f"/users/matthias/Documents/GitHub/engx-project-group20/skjölin frá Birgi/Files/Arsreikningar-lifeyrissjoda_{year}.xlsx"
        
        subfunds = read_subfunds(file_name, year)
        all_subfunds = pd.concat([all_subfunds, subfunds], ignore_index=True)

    unique_subfunds = remove_duplicates(all_subfunds)
    print(unique_subfunds)

    unique_subfunds.to_csv("unique_subfunds.csv", index=False)

if __name__ == "__main__":
    main()