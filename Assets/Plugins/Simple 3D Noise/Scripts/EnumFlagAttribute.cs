using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnumFlagAttribute : PropertyAttribute
{
    public string name;

    public EnumFlagAttribute() { }

    public EnumFlagAttribute(string name)
    {
        this.name = name;
    }
}
