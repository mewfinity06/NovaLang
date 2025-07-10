# Enums

## Form

 - 'const' %ident ':' 'enum' '=' '{' <ENUMBODY> '}' ';'

## Examples

```
const Day : enum = {
    Sun, Mon,
    Tue, Wed,
    Thu, Fri,
    Sat,
};

// Enums are tagged unions
const Activity : enum {
    Todo: str,
    SwimLaps: i8,
    Meditate: struct {
        times: i8,
        seconds: f16,
    },
    NoMore,
};

const do_activity : fn(activity: Activity) -> void = {
    switch (activity) {
        .Todo     : |todo| => { printf("TODO: {s}\n", todo); },
        .SwimLaps : |laps| => printf("Swim {d} laps\n", laps),
        .Meditate : |med|  => {
            printf("Meditate {d} times for {f} seconds\n", med.times, med.seconds);
        },
        .NoMore => return,
    };
};

```
