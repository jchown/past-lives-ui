import { defineStore } from 'pinia'
import { useLocalStorage } from '@vueuse/core'

export const useUserStore = defineStore('user', {
    state: () => {
      return { 
        name: useLocalStorage('name', ""),
        dayOfBirth: useLocalStorage('dayOfBirth', ""),
        monthOfBirth: useLocalStorage('monthOfBirth', ""),
        yearOfBirth: useLocalStorage('yearOfBirth', ""),
        ensoulmentDay: useLocalStorage('ensoulmentDay', 0),
        famous: useLocalStorage('famous', true),
      }
    },

    actions: {
        setName(name) {
            this.name = name
        },
        setDayOfBirth(dayOfBirth) {
            this.dayOfBirth = dayOfBirth
        },
        setMonthOfBirth(monthOfBirth) {
            this.monthOfBirth = monthOfBirth
        },
        setYearOfBirth(yearOfBirth) {
            this.yearOfBirth = yearOfBirth
        },
        setEnsoulmentDay(ensoulmentDay) {
            this.ensoulmentDay = ensoulmentDay
        },
        setFamous(famous) {
            this.famous = famous
        }
    },
  })