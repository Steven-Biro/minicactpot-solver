# cython: language_level=3, boundscheck=False
import numpy as np
import itertools


rewards = np.array([10000, 36, 720, 360, 80, 252, 108, 72, 54, 180, 72, 180, 119, 36, 306, 1080, 144, 1800, 3600])
cdef list boards = list(itertools.permutations([1, 2, 3, 4, 5, 6, 7, 8, 9]))
pos_ans = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]


cdef list GetValidBoards(vals):
    cdef list validboards = []
    for possibility in boards:
        flag = True
        for val in vals:
            if possibility[val[0]] != val[1]:
                flag = False
                break
        if flag is False:
            continue
        validboards.append(possibility)
    return validboards

def ChooseNumber(board):
    cdef list vals = list([[board.index(s), int(s)] for s in board if type(s) is type(1)])
    validboards = GetValidBoards(vals)
    results = [CheckBoard(x) for x in validboards]
    value = np.sum(results, axis=0)

    for val in vals:
        value[val[0]] = 0
    return int(np.where(value == max(value))[0][0] + 1)


def CheckBoard(possibility):
    sums = np.array([
                    possibility[0] + possibility[1] + possibility[2],
                    possibility[3] + possibility[4] + possibility[5],
                    possibility[6] + possibility[7] + possibility[8],
                    possibility[0] + possibility[3] + possibility[6],
                    possibility[1] + possibility[4] + possibility[7],
                    possibility[2] + possibility[5] + possibility[8],
                    possibility[0] + possibility[4] + possibility[8],
                    possibility[2] + possibility[4] + possibility[6],
                    ])


    value = np.array([rewards[sums[0] - 6] + rewards[sums[3] - 6] + rewards[sums[6] - 6],
                      rewards[sums[0] - 6] + rewards[sums[4] - 6],
                      rewards[sums[0] - 6] + rewards[sums[5] - 6] + rewards[sums[7] - 6],
                      rewards[sums[1] - 6] + rewards[sums[3] - 6],
                      rewards[sums[1] - 6] + rewards[sums[4] - 6] + rewards[sums[6] - 6] + rewards[sums[7] - 6],
                      rewards[sums[1] - 6] + rewards[sums[5] - 6],
                      rewards[sums[2] - 6] + rewards[sums[3] - 6] + rewards[sums[7] - 6],
                      rewards[sums[1] - 6] + rewards[sums[5] - 6],
                      rewards[sums[2] - 6] + rewards[sums[5] - 6] + rewards[sums[6] - 6]])
    return value

def PickRow(board):
    cdef list vals = list([[board.index(s), int(s)] for s in board if type(s) is type(1)])
    validboards = GetValidBoards(vals)

    results = [CheckRow(x) for x in validboards]
    value = np.sum(results, axis=0)
    value = sorted([[pos_ans[i], value[i]] for i in range(len(pos_ans))],
                   key=lambda l: l[1], reverse=True)
    return value[0][0]

def CheckRow(possibility):
    value = np.zeros(8)
    sums = np.array([
                    possibility[0] + possibility[1] + possibility[2],
                    possibility[3] + possibility[4] + possibility[5],
                    possibility[6] + possibility[7] + possibility[8],
                    possibility[0] + possibility[3] + possibility[6],
                    possibility[1] + possibility[4] + possibility[7],
                    possibility[2] + possibility[5] + possibility[8],
                    possibility[0] + possibility[4] + possibility[8],
                    possibility[2] + possibility[4] + possibility[6],
                    ])


    for i in range(len(value)):
        value[i] = rewards[sums[i] - 6]

    return value

