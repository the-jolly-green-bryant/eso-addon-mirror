# LibDataStructures

**LibDataStructures** is a lightweight library for The Elder Scrolls Online (ESO) that provides developers with essential data structures to enhance their addon development.

---

## Features

- **Stack**:
  - Push values onto the stack.
  - Pop values from the stack.
  - Peek at the top value without removing it.
  - Clear all values from the stack.
  - Clone the stack for independent manipulation.
  - Iterate over stack elements from top to bottom.
  - Check if the stack is empty.
  - Get the current size of the stack.

- **Queue**:
  - Enqueue adds an element to the end of the Queue
  - Dequeue returns the first element in the Queue and deletes it
  - Peek returns the first element in the Queue
  - IsEmpty checks if the Queue is empty
  - Len returns the amount of elements in the Queue
  - Iterate creates an iterator over all elements
  - Clear removes all elements in the Queue
  - Copy creates a shallow copy of the current Queue

---

## Installation

1. Download the latest release of the library from [GitHub](#).
2. Place the `LibDataStructures` folder into your `AddOns` directory:
    ```
    Documents/Elder Scrolls Online/live/AddOns/
    ```
3. Add the library dependency to your addon’s manifest file (`.txt`):
    ```
    DependsOn: LibDataStructures>=20241127
    ```

---

## Usage

Here is an example of how to use LibDataStructures to work with a stack:

### Initialization
```lua
local LDS = LibDataStructures
local stack = LDS.Stack:New()
```

### Basic Operations
```lua
-- Push values onto the stack
stack:Push(10)
stack:Push(20)

-- Peek at the top value
d(stack:Peek()) -- Output: 20

-- Pop values from the stack
d(stack:Pop()) -- Output: 20
d(stack:Pop()) -- Output: 10
```

### Utility Functions
```lua
-- Check if the stack is empty
d(stack:IsEmpty()) -- Output: true

-- Clear the stack
stack:Push(1)
stack:Push(2)
stack:Clear()
d(stack:Len()) -- Output: 0

-- Clone the stack
stack:Push(100)
local clonedStack = stack:Clone()
d(clonedStack:Pop()) -- Output: 100
```

### Iteration
```lua
-- Push multiple values
stack:Push(1)
stack:Push(2)
stack:Push(3)

-- Iterate through the stack
for value in stack:Iterate() do
    d(value) -- Output: 3, 2, 1
end
```

---

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests for improvements, bug fixes, or new data structures.